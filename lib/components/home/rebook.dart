import 'package:flutter/material.dart';
import 'package:duckhat/components/home/rebookcard.dart';

class EmptyRebookState extends StatelessWidget {
  const EmptyRebookState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history, color: Colors.black54),
            SizedBox(height: 6),
            Text(
              "Você ainda não possui serviços recentes",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class RebookSection extends StatelessWidget {
  final List rebookServices;

  const RebookSection({super.key, required this.rebookServices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Agende novamente:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 12),

        /// estado vazio
        if (rebookServices.isEmpty)
          const EmptyRebookState()
        /// lista horizontal
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rebookServices.length,
              itemBuilder: (context, index) {
                final service = rebookServices[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: RebookCard(
                    name: service["name"],
                    image: service["image"],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
