import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:duckhat/components/home/header.dart';
import 'package:duckhat/components/home/rebook.dart';
import 'package:duckhat/components/home/appointment.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/pages/search.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final username = DuckHatApi.instance.currentSession?.nome;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            key: const PageStorageKey('home-scroll'),
            cacheExtent: 500,
            children: [
              HomeHeader(username: username),
              const SizedBox(height: 10),
              const _SearchShortcut(),
              const SizedBox(height: 20),
              const _PromoBanner(),
              const SizedBox(height: 20),
              RebookSection(
                rebookServices: const [
                  {
                    "name": "Barbie's Salon",
                    "image": "assets/barbiesalon.jpg",
                    "rating": 4.8,
                    "reviews": 120,
                  },
                  {
                    "name": "James Salon",
                    "image": "assets/jamessalon.jpg",
                    "rating": 4.5,
                    "reviews": 85,
                  },
                ],
              ),
              const SizedBox(height: 20),
              AppointmentSection(
                appointments: const [
                  {
                    "time": "14:30",
                    "service": "Corte de cabelo",
                    "place": "M&L Encanamentos LTDA",
                    "image": "assets/mariano.jpg",
                  },
                  {
                    "time": "16:00",
                    "service": "Manicure",
                    "place": "Salão Beleza",
                    "image": "assets/salao.jpg",
                  },
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchShortcut extends StatelessWidget {
  const _SearchShortcut();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(AppRoute(builder: (_) => const SearchPage()));
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.accent),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Buscar serviços, profissionais ou reparos',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textRegular,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.tune, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowAccent,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Encontre os\nmelhores serviços",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                _PromoButton(),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(35)),
            child: Image.asset("assets/niceduck.jpg", fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _PromoButton extends StatelessWidget {
  const _PromoButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Ver promoções",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
