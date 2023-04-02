import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compile_project/domain/entities/pokemon_detail_entity.dart';
import 'package:compile_project/presentation/pages/home/home_screen_controller.dart';
import 'package:compile_project/presentation/widgets/pokemon_widget.dart';

class SelectedPokemos extends ConsumerStatefulWidget {
  const SelectedPokemos({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FavouritesWidgetState();
}

class _FavouritesWidgetState extends ConsumerState<SelectedPokemos> {
  late TextEditingController _searchController;
  String _searchTerm = '';
  bool searchInPage = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _onTapPokemon(PokemonDetailEntity pokemonDetail) {
    Navigator.of(context)
        .pushNamed('pokemonDetail', arguments: {'detail': pokemonDetail});
  }

  Widget _buildSearchBox() {
    return searchInPage
        ? TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'חפש פוקימון',
              border: OutlineInputBorder(),
              icon: Icon(Icons.search),
            ),
          )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      List<PokemonDetailEntity> favourites = ref.watch(favouriteListProvider);
      List<PokemonDetailEntity> filteredFavourites =
          favourites.where((pokemon) {
        return pokemon.name.contains(_searchTerm);
      }).toList();

      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              searchInPage = !searchInPage;
            });
          },
          icon: !searchInPage
              ? Icon(
                  Icons.search,
                )
              : Icon(Icons.search_off),
          label:
              !searchInPage ? Text("חפש בפוקימונים שלך") : Text("צא מהחיפוש"),
        ),
        body: Column(
          children: [
            _buildSearchBox(),
            Expanded(
              child: filteredFavourites.isEmpty
                  ? const Center(
                      child: Text('לא הוספת פוקימונים, נא חפש חדשים'),
                    )
                  : GridView.builder(
                      key: const PageStorageKey('my_pokemons'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                        crossAxisCount: 2,
                        mainAxisExtent: 186,
                      ),
                      itemCount: filteredFavourites.length,
                      itemBuilder: (context, index) => PokemonWidget(
                        pokemonDetail: filteredFavourites[index],
                        onTap: () => _onTapPokemon(filteredFavourites[index]),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
