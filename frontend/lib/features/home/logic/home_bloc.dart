import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/data/repositories/home_repository.dart';
import 'package:frontend/features/home/logic/home_event.dart';
import 'package:frontend/features/home/logic/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadDiscountedProducts>(_onLoadDiscountedProducts);

    on<HomeEvent>((event, emit) async {
      if (event is LoadAllProducts || event is LoadDiscountedProducts) {
        emit(HomeLoading());
        try {
          final all = await repository.getAllProducts();
          final discounts = await repository.getDiscountedProducts();
          print(all);
          print(discounts);
          emit(HomeLoaded(allProducts: all, discountedProducts: discounts));
        } catch (e) {
          emit(HomeError(e.toString()));
        }
      }
    });
  }

  Future<void> _onLoadAllProducts(
      LoadAllProducts event, Emitter<HomeState> emit) async {}

  Future<void> _onLoadDiscountedProducts(
      LoadDiscountedProducts event, Emitter<HomeState> emit) async {}
}
