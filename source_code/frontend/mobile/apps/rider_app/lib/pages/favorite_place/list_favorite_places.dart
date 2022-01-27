import 'package:flutter/material.dart';
import 'package:rider_app/pages/favorite_place/add_favorite_place.dart';
import 'package:rider_app/pages/favorite_place/edit_favorite_place.dart';
import 'package:shared/shared.dart';

class ListFavoritePlaces extends StatefulWidget {
  final Account _riderAccount;
  const ListFavoritePlaces(this._riderAccount, {Key? key}) : super(key: key);

  @override
  State<ListFavoritePlaces> createState() => _ListFavoritePlacesState();
}

class _ListFavoritePlacesState extends State<ListFavoritePlaces> {
  bool _isLoading = true;
  List<Map<String, String>> _favoritePlaces = [];
  final _favoritePlaceRepository = FavoritePlaceRepository();

  @override
  void initState() {
    super.initState();
    _fetchFavoritePlaces();
  }

  Future<void> _fetchFavoritePlaces() async {
    final accessToken = await widget._riderAccount.accessToken;
    final response = await _favoritePlaceRepository.get(
      {"rider_id": widget._riderAccount.id},
      accessToken!,
    );
    setState(() {
      _favoritePlaces = List.from(response["data"]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Places"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddFavoritePlacePage(widget._riderAccount);
                  },
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            )
          : _favoritePlaces.isEmpty
              ? const Center(
                  child: Text("You don't have any Favorite place yet."),
                )
              : ListView.builder(
                  itemCount: _favoritePlaces.length,
                  itemBuilder: (context, index) {
                    final place = _favoritePlaces[index];
                    return ListTile(
                      title: Text(place["place_label"]!),
                      subtitle: Text(place["street_address"]!),
                      onTap: () async {
                        final accessToken =
                            await widget._riderAccount.accessToken;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return EditFavoritePlacePage(
                                place["place_label"]!,
                                place["street_address"]!,
                                accessToken!,
                                place["id"]!,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
