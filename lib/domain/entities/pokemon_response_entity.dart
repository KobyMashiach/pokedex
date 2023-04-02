import 'package:equatable/equatable.dart';
import 'package:compile_project/domain/entities/pokemon_entity.dart';

class PokemonResponseEntity extends Equatable {
  final String? next;
  final List<PokemonEntity> pokemons;
  const PokemonResponseEntity({required this.next, required this.pokemons});

  @override
  List<Object?> get props => [pokemons];
}
