import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:duckhat/components/home/header.dart';
import 'package:duckhat/components/home/searchbar.dart';
import 'package:duckhat/components/home/filtersection.dart';
import 'package:duckhat/components/home/rebook.dart';
import 'package:duckhat/components/home/appointment.dart';
import 'package:duckhat/components/bottomnav.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  int selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),

      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 232, 241, 255),

        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),

                const SizedBox(height: 10),

                SearchDuck(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),

                const SizedBox(height: 16),

                const FilterSection(),

                const SizedBox(height: 20),

                const RebookSection(rebookServices: []),

                const SizedBox(height: 20),

                const AppointmentSection(appointments: []),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),

        bottomNavigationBar: DuckHatBottomNav(
          selectedIndex: selectedNavIndex,
          onTap: (index) {
            setState(() {
              selectedNavIndex = index;
            });
          },
        ),
      ),
    );
  }
}
