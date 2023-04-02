import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compile_project/constants/color_constants.dart';
import 'package:compile_project/domain/entities/pokemon_detail_entity.dart';
import 'package:compile_project/presentation/pages/pokemon_detail/pokemon_detail_controller.dart';
import 'package:compile_project/presentation/widgets/pokemon_detail_header.dart';

class PokemonDetailScreen extends ConsumerStatefulWidget {
  final PokemonDetailEntity pokemonDetailEntity;
  const PokemonDetailScreen({
    Key? key,
    required this.pokemonDetailEntity,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> {
  @override
  void initState() {
    ref
        .read(pokemonDetailControllerProvider)
        .checkIffavourite(widget.pokemonDetailEntity.name.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          bool isFavourite = ref.watch(pokemonStateProvider);
          return FloatingActionButton.extended(
            label: Text(
              isFavourite ? 'הסר מהפוקימונים שלי' : 'הוסף לפוקימונים שלי',
              style: TextStyle(
                  color: isFavourite
                      ? Color.fromARGB(255, 255, 255, 255)
                      : Color.fromARGB(255, 0, 0, 0)),
            ),
            backgroundColor: isFavourite
                ? Color.fromARGB(255, 158, 13, 13)
                : Color.fromARGB(255, 255, 147, 147),
            onPressed: () async {
              if (!isFavourite) {
                await ref
                    .read(pokemonDetailControllerProvider)
                    .markAsFavourite(widget.pokemonDetailEntity);
              } else {
                await ref
                    .read(pokemonDetailControllerProvider)
                    .removeFromFavourites(widget.pokemonDetailEntity);
              }
            },
          );
        },
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: const BackButton(color: ColorConstants.grey),
            pinned: true,
            backgroundColor: Colors.green[50],
            expandedHeight: 50,
            forceElevated: true,
            elevation: 2,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                PokemonDetailDisplay(
                    pokemonDetailEntity: widget.pokemonDetailEntity),
                // PokemonShapeInfo(
                //     pokemonDetailEntity: widget.pokemonDetailEntity),
                // PokemonStatWidget(
                //   pokemonDetailEntity: widget.pokemonDetailEntity,
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
