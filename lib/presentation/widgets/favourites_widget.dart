import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compile_project/domain/entities/pokemon_detail_entity.dart';
import 'package:compile_project/presentation/pages/home/home_screen_controller.dart';
import 'package:compile_project/presentation/widgets/pokemon_widget.dart';

import 'package:http/http.dart' as http;

class SelectedPokemos extends ConsumerStatefulWidget {
  const SelectedPokemos({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FavouritesWidgetState();
}

class _FavouritesWidgetState extends ConsumerState<SelectedPokemos> {
  late TextEditingController _searchController;
  String _searchTerm = '';
  String _searchInList = '';
  bool searchInPage = false;
  late TextEditingController _searchAllPokemonsController;
  List<PokemonDetailEntity> pokemonList = [];

  Future<void> getAllPokemon() async {
    pokemonList = [];
    bool nextExists = true;
    String nextUrl = 'https://pokeapi.co/api/v2/pokemon';
    while (nextExists) {
      var response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        for (var pokemonData in data['results']) {
          var pokemonResponse = await http.get(Uri.parse(pokemonData['url']));
          if (pokemonResponse.statusCode == 200) {
            var pokemonDetails = jsonDecode(pokemonResponse.body);
            var pokemon = PokemonDetailEntity(
              id: pokemonDetails['id'],
              name: pokemonDetails['name'],
              speciesTypes: [
                pokemonDetails['species']['name'],
                ...pokemonDetails['types']
                    .map((type) => type['type']['name'])
                    .toList(),
              ],
              imageUrl: pokemonDetails['sprites']['front_default'],
              height: pokemonDetails['height'],
              weight: pokemonDetails['weight'],
              bmi: calculateBMI(
                  pokemonDetails['height'], pokemonDetails['weight']),
              isFavourite: false,
            );
            pokemonList.add(pokemon);
          } else {
            print('Request failed with status: ${pokemonResponse.statusCode}.');
          }
        }
        if (data['next'] == null) {
          nextExists = false;
        } else {
          // nextUrl = data['next'];
          nextExists = false;
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return;
      }
    }
    print(pokemonList.toString());
  }

  double calculateBMI(int height, int weight) {
    return weight / ((height / 100) * (height / 100));
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    _searchAllPokemonsController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAllPokemonsController.dispose();
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

  Widget _searchInAllPokemons() {
    return Container(
      color: const Color.fromARGB(255, 114, 0, 0),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: _searchAllPokemonsController,
        onChanged: (value) {
          setState(() {
            _searchInList = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'הוסף פוקימון מהרשימה',
          hintStyle: TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          icon: Icon(
            Icons.manage_search_outlined,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      !searchInPage ? _searchTerm = "" : null;
    });

    return Consumer(builder: (context, ref, child) {
      List<PokemonDetailEntity> myPokemons = ref.watch(myPokemonsListProvider);
      List<PokemonDetailEntity> filteredMyPokemons =
          myPokemons.where((pokemon) {
        return pokemon.name.contains(_searchTerm);
      }).toList();

      List<PokemonDetailEntity> filteredAllPokemons =
          pokemonList.where((pokemon) {
        return pokemon.name.contains(_searchInList);
      }).toList();

      return FutureBuilder(
          future: getAllPokemon(),
          builder: (context, snapshot) => snapshot.connectionState ==
                      ConnectionState.waiting &&
                  snapshot.hasData
              ? const Center(
                  child: Column(
                  children: [
                    Text('טוען פוקימונים'),
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                  ],
                ))
              : Scaffold(
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () {
                      setState(() {
                        searchInPage = !searchInPage;
                        _searchController.clear();
                      });
                    },
                    icon: !searchInPage
                        ? const Icon(
                            Icons.search,
                          )
                        : const Icon(Icons.search_off),
                    label: !searchInPage
                        ? Text("חפש בפוקימונים שלך")
                        : Text("צא מהחיפוש"),
                  ),
                  body: Column(
                    children: [
                      _searchInAllPokemons(),
                      _buildSearchBox(),
                      Expanded(
                        child: filteredMyPokemons.isEmpty
                            ? const Center(
                                child: Text('לא הוספת פוקימונים, נא חפש חדשים'),
                              )
                            : GridView.builder(
                                key: const PageStorageKey('all_pokemons'),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 12,
                                  crossAxisCount: 2,
                                  mainAxisExtent: 186,
                                ),
                                itemCount: _searchInList.length < 2
                                    ? filteredMyPokemons.length
                                    : filteredAllPokemons.length,
                                itemBuilder: (context, index) => PokemonWidget(
                                  pokemonDetail: _searchInList.length < 2
                                      ? filteredMyPokemons[index]
                                      : filteredAllPokemons[index],
                                  onTap: () => _onTapPokemon(
                                      _searchInList.length < 2
                                          ? filteredMyPokemons[index]
                                          : filteredAllPokemons[index]),
                                ),
                              ),
                      ),
                    ],
                  ),
                ));
    });
  }
}
