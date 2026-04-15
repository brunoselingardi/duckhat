import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:duckhat/components/home/header.dart';
import 'package:duckhat/components/home/searchbar.dart';
import 'package:duckhat/components/home/filtersection.dart';
import 'package:duckhat/components/home/rebook.dart';
import 'package:duckhat/components/home/appointment.dart';
import 'package:duckhat/theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 10),
                    const SearchDuck(),
                    const SizedBox(height: 16),
                    const FilterSection(),
                    const SizedBox(height: 20),
                    Container(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Encontre os\nmelhores serviços",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
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
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Image.asset(
                              "assets/niceduck.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RebookSection(
                      rebookServices: const [
                        {
                          "name": "Barbie's Salon",
                          "image": "assets/barbiesalon.png",
                          "rating": 4.8,
                          "reviews": 120,
                        },
                        {
                          "name": "James Salon",
                          "image": "assets/jamessalon.png",
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
                          "image": "assets/mariano.png",
                        },
                        {
                          "time": "16:00",
                          "service": "Manicure",
                          "place": "Salão Beleza",
                          "image": "assets/salao.png",
                        },
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
