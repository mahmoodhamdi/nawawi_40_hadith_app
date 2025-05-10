import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith_nawawi_audio/widgets/hadith_tile.dart';

import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HadithCubit()..fetchHadiths(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('الأربعون النووية'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'مرحباً بك في تطبيق الأربعين النووية',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن حديث...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                              : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<HadithCubit, HadithState>(
                      builder: (context, state) {
                        if (state is HadithLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is HadithLoaded) {
                          final filtered =
                              _searchQuery.isEmpty
                                  ? state.hadiths
                                  : state.hadiths
                                      .where(
                                        (h) =>
                                            h.hadith.contains(_searchQuery) ||
                                            h.description.contains(
                                              _searchQuery,
                                            ),
                                      )
                                      .toList();
                          if (filtered.isEmpty) {
                            return const Center(
                              child: Text('لا يوجد نتائج للبحث.'),
                            );
                          }
                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final hadith = filtered[index];
                              // The index+1 should reflect the original hadith number if possible
                              final originalIndex =
                                  state.hadiths.indexOf(hadith) + 1;
                              return HadithTile(
                                index: originalIndex,
                                hadith: hadith,
                                searchQuery: _searchQuery,
                              );
                            },
                          );
                        } else if (state is HadithError) {
                          return Center(child: Text(state.message));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
