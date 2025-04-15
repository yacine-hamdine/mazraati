import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/logic/home_bloc.dart';
import 'package:frontend/features/home/logic/home_event.dart';
import 'package:frontend/features/home/logic/home_state.dart';
import 'package:frontend/features/home/presentation/widgets/discounted_section.dart';
import 'package:frontend/features/home/presentation/widgets/product_section.dart';
import 'package:frontend/features/home/data/models/product_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(repository: context.read())..add(LoadAllProducts()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🏠 Home'),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeError) {
              return Center(child: Text("❌ ${state.message}"));
            } else if (state is HomeLoaded) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DiscountedSection(products: state.discountedProducts),
                  const SizedBox(height: 24),
                  ..._buildProductSections(state.allProducts),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildProductSections(List allProducts) {
    final Map<String, List> grouped = {};

    for (var product in allProducts) {
      grouped.putIfAbsent(product.category, () => []).add(product);
    }

    return grouped.entries
        .map((e) => ProductSection(category: e.key, products: e.value.cast<Product>()))
        .toList();
  }
}
