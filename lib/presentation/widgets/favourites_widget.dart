import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compile_project/domain/entities/pokemon_detail_entity.dart';
import 'package:compile_project/presentation/pages/home/home_screen_controller.dart';
import 'package:compile_project/presentation/widgets/pokemon_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  late List<dynamic> pokemonList;

  Future<void> getAllPokemon() async {
    pokemonList = [];
    bool nextExists = true;
    String nextUrl = 'https://pokeapi.co/api/v2/pokemon';
    while (nextExists) {
      var response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        pokemonList.addAll(data['results']);
        if (data['next'] == null) {
          nextExists = false;
        } else {
          nextUrl = data['next'];
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return;
      }
    }
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

      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              searchInPage = !searchInPage;
              _searchController.clear();
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
            _searchInAllPokemons(),
            _buildSearchBox(),
            FutureBuilder(
                future: getAllPokemon(),
                builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: Column(
                          children: [
                            Text('טוען פוקימונים'),
                            SizedBox(height: 20),
                            CircularProgressIndicator(),
                          ],
                        ))
                      : Expanded(
                          child: filteredMyPokemons.isEmpty
                              ? const Center(
                                  child:
                                      Text('לא הוספת פוקימונים, נא חפש חדשים'),
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
                                  itemCount: filteredMyPokemons.length,
                                  itemBuilder: (context, index) =>
                                      PokemonWidget(
                                    pokemonDetail: filteredMyPokemons[index],
                                    onTap: () => _onTapPokemon(
                                        filteredMyPokemons[index]),
                                  ),
                                ),
                        );
                }),
          ],
        ),
      );
    });
  }
}
