package com.duckhat.api.service;

import com.duckhat.api.entity.Usuario;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Base64;
import java.util.UUID;

@Service
public class SmtpRecuperacaoSenhaEmailSender implements RecuperacaoSenhaEmailSender {

  private static final String CRLF = "\r\n";
  private static final DateTimeFormatter EXPIRACAO_FORMATTER =
      DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

  private final boolean enabled;
  private final String host;
  private final int port;
  private final String username;
  private final String password;
  private final String from;
  private final String fromName;
  private final boolean auth;
  private final boolean ssl;
  private final boolean startTls;
  private final int connectTimeoutMs;
  private final int readTimeoutMs;

  public SmtpRecuperacaoSenhaEmailSender(
      @Value("${app.email.enabled:true}") boolean enabled,
      @Value("${app.email.host:}") String host,
      @Value("${app.email.port:587}") int port,
      @Value("${app.email.username:}") String username,
      @Value("${app.email.password:}") String password,
      @Value("${app.email.from:no-reply@duckhat.local}") String from,
      @Value("${app.email.from-name:DuckHat}") String fromName,
      @Value("${app.email.auth:true}") boolean auth,
      @Value("${app.email.ssl:false}") boolean ssl,
      @Value("${app.email.start-tls:true}") boolean startTls,
      @Value("${app.email.connect-timeout-ms:10000}") int connectTimeoutMs,
      @Value("${app.email.read-timeout-ms:10000}") int readTimeoutMs
  ) {
    this.enabled = enabled;
    this.host = normalizar(host);
    this.port = port;
    this.username = normalizar(username);
    this.password = password == null ? "" : password;
    this.from = normalizar(from);
    this.fromName = normalizar(fromName);
    this.auth = auth;
    this.ssl = ssl;
    this.startTls = startTls;
    this.connectTimeoutMs = connectTimeoutMs;
    this.readTimeoutMs = readTimeoutMs;
  }

  @Override
  public boolean configurado() {
    if (!enabled || host.isBlank() || from.isBlank()) {
      return false;
    }
    return !auth || (!username.isBlank() && !password.isBlank());
  }

  @Override
  public void enviarCodigo(Usuario usuario, String codigo, LocalDateTime expiraEm) {
    if (!configurado()) {
      throw new RecuperacaoSenhaEmailException("Envio de e-mail de recuperacao nao configurado.");
    }

    String destinatario = sanitizarEmail(usuario.getEmail());
    String assunto = "Código de recuperação DuckHat";
    String mensagem = montarMensagem(usuario, destinatario, assunto, codigo, expiraEm);

    try {
      enviar(destinatario, mensagem);
    } catch (IOException ex) {
      throw new RecuperacaoSenhaEmailException("Falha ao enviar e-mail de recuperacao.", ex);
    }
  }

  private String montarMensagem(
      Usuario usuario,
      String destinatario,
      String assunto,
      String codigo,
      LocalDateTime expiraEm
  ) {
    String nome = normalizar(usuario.getNome());
    String saudacao = nome.isBlank() ? "Olá." : "Olá, " + nome + ".";
    String corpo = String.join(CRLF,
        saudacao,
        "",
        "Use o código abaixo para redefinir sua senha no DuckHat:",
        "",
        codigo,
        "",
        "Este código expira em " + EXPIRACAO_FORMATTER.format(expiraEm)
            + " no horário local do servidor.",
        "",
        "Se você não solicitou a recuperação de senha, ignore este e-mail."
    );

    return String.join(CRLF,
        "From: " + formatarEndereco(fromName, from),
        "To: " + formatarEndereco(nome, destinatario),
        "Subject: " + codificarHeader(assunto),
        "MIME-Version: 1.0",
        "Content-Type: text/plain; charset=UTF-8",
        "Content-Transfer-Encoding: 8bit",
        "Date: " + DateTimeFormatter.RFC_1123_DATE_TIME.format(ZonedDateTime.now()),
        "Message-ID: <" + UUID.randomUUID() + "@" + dominioMessageId() + ">",
        "",
        corpo
    );
  }

  private void enviar(String destinatario, String mensagem) throws IOException {
    Socket socket = abrirSocket();
    SmtpSession session = new SmtpSession(socket);

    try {
      session.expect(220);
      session.command("EHLO duckhat.local", 250);

      if (startTls && !ssl) {
        session.command("STARTTLS", 220);
        socket = criarSocketTls(socket);
        session.replaceSocket(socket);
        session.command("EHLO duckhat.local", 250);
      }

      if (auth) {
        session.command("AUTH LOGIN", 334);
        session.command(codificarBase64(username), 334);
        session.command(codificarBase64(password), 235);
      }

      session.command("MAIL FROM:<" + sanitizarEmail(from) + ">", 250);
      session.command("RCPT TO:<" + destinatario + ">", 250, 251);
      session.command("DATA", 354);
      session.writeData(mensagem);
      session.expect(250);
      session.command("QUIT", 221, 250);
    } finally {
      session.close();
    }
  }

  private Socket abrirSocket() throws IOException {
    Socket socket = ssl
        ? ((SSLSocketFactory) SSLSocketFactory.getDefault()).createSocket()
        : new Socket();
    socket.connect(new InetSocketAddress(host, port), connectTimeoutMs);
    socket.setSoTimeout(readTimeoutMs);
    if (socket instanceof SSLSocket sslSocket) {
      sslSocket.startHandshake();
    }
    return socket;
  }

  private Socket criarSocketTls(Socket socket) throws IOException {
    SSLSocket sslSocket = (SSLSocket) ((SSLSocketFactory) SSLSocketFactory.getDefault())
        .createSocket(socket, host, port, true);
    sslSocket.setSoTimeout(readTimeoutMs);
    sslSocket.startHandshake();
    return sslSocket;
  }

  private String formatarEndereco(String nome, String email) {
    String emailSeguro = sanitizarEmail(email);
    String nomeSeguro = normalizar(nome).replace("\"", "");
    if (nomeSeguro.isBlank()) {
      return "<" + emailSeguro + ">";
    }
    return codificarHeader(nomeSeguro) + " <" + emailSeguro + ">";
  }

  private String sanitizarEmail(String email) {
    String normalizado = normalizar(email);
    if (normalizado.isBlank()
        || normalizado.contains("\r")
        || normalizado.contains("\n")
        || !normalizado.contains("@")) {
      throw new RecuperacaoSenhaEmailException("Endereco de e-mail invalido para envio.");
    }
    return normalizado;
  }

  private String dominioMessageId() {
    if (from.contains("@")) {
      return from.substring(from.indexOf('@') + 1);
    }
    return "duckhat.local";
  }

  private static String normalizar(String value) {
    return value == null ? "" : value.trim();
  }

  private static String codificarHeader(String value) {
    return "=?UTF-8?B?" + codificarBase64(value) + "?=";
  }

  private static String codificarBase64(String value) {
    return Base64.getEncoder().encodeToString(value.getBytes(StandardCharsets.UTF_8));
  }

  private static class SmtpSession {
    private Socket socket;
    private BufferedReader reader;
    private BufferedWriter writer;

    private SmtpSession(Socket socket) throws IOException {
      replaceSocket(socket);
    }

    private void replaceSocket(Socket socket) throws IOException {
      this.socket = socket;
      this.reader = new BufferedReader(
          new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
      this.writer = new BufferedWriter(
          new OutputStreamWriter(socket.getOutputStream(), StandardCharsets.UTF_8));
    }

    private void command(String command, int... expectedCodes) throws IOException {
      writer.write(command);
      writer.write(CRLF);
      writer.flush();
      expect(expectedCodes);
    }

    private void writeData(String message) throws IOException {
      String normalized = message.replace("\r\n", "\n").replace("\r", "\n");
      for (String line : normalized.split("\n", -1)) {
        if (line.startsWith(".")) {
          writer.write(".");
        }
        writer.write(line);
        writer.write(CRLF);
      }
      writer.write(".");
      writer.write(CRLF);
      writer.flush();
    }

    private void expect(int... expectedCodes) throws IOException {
      SmtpResponse response = readResponse();
      boolean expected = Arrays.stream(expectedCodes).anyMatch(code -> code == response.code());
      if (!expected) {
        throw new IOException("Resposta SMTP inesperada: " + response.summary());
      }
    }

    private SmtpResponse readResponse() throws IOException {
      String line = reader.readLine();
      if (line == null) {
        throw new IOException("Servidor SMTP encerrou a conexao.");
      }

      StringBuilder response = new StringBuilder(line);
      int code = parseCode(line);
      while (line.length() > 3 && line.charAt(3) == '-') {
        line = reader.readLine();
        if (line == null) {
          throw new IOException("Servidor SMTP encerrou a conexao.");
        }
        response.append(" | ").append(line);
      }
      return new SmtpResponse(code, response.toString());
    }

    private int parseCode(String line) throws IOException {
      if (line.length() < 3) {
        throw new IOException("Resposta SMTP invalida: " + line);
      }
      try {
        return Integer.parseInt(line.substring(0, 3));
      } catch (NumberFormatException ex) {
        throw new IOException("Resposta SMTP invalida: " + line, ex);
      }
    }

    private void close() throws IOException {
      socket.close();
    }
  }

  private record SmtpResponse(int code, String summary) {
  }
}
