import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compile_project/constants/color_constants.dart';
import 'package:compile_project/constants/image_constants.dart';
import 'package:compile_project/domain/entities/pokemon_detail_entity.dart';
import 'package:compile_project/presentation/pages/home/home_screen_controller.dart';
import 'package:compile_project/presentation/widgets/all_pokemon_widget.dart';
import 'package:compile_project/presentation/widgets/favourites_widget.dart';
import 'package:compile_project/presentation/widgets/home_screen_appbar_title.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    ref.read(homeScreenControllerProvider).getFavourites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const HomeScreenAppBarTitle(),
        ),
        body: const SelectedPokemos(),

        // const TabBarView(
        //   children: [
        // AllPokemonWidget(),
        //     FavouritesWidget(),
        //   ],
        // ),
      ),
    );
  }
}
