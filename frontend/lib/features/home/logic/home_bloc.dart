import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../data/repositories/home_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository? homeRepository;

  HomeBloc({this.homeRepository}) : super(HomeLoading()) {
    on<LoadHome>(_onLoadData);
  }

  void _onLoadData(LoadHome event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final banners = await homeRepository!.getBanners();
      final products = await homeRepository!.getProducts();
      emit(HomeLoaded(banners: banners, products: products));
    } catch (e) {
      emit(HomeError('Erreur lors du chargement des données'));
    }
  }
}
