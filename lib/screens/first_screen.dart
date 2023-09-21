import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sazamtomp3/constants/routes.dart';
import 'package:sazamtomp3/helpers/shrink_text.dart';
import 'package:sazamtomp3/services/youtube_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final YouTubeService _youTubeService = YouTubeService();
  TextEditingController _textController = TextEditingController();
  FocusScopeNode _focusScopeNode = FocusScopeNode();

  bool _isSearching = false;
  bool _isLoadingSong = false;
  Video? _video;
  bool _redirectToSongScreen = false;

  DateTime _lastChangeTime = DateTime.now();

  final StreamController<List<Video>> _searchResultsController = StreamController<List<Video>>.broadcast();
  
  Stream<List<Video>>? _searchResults;

  @override
  void initState() {
    _searchResults = _searchResultsController.stream;

    _textController = TextEditingController();
    _focusScopeNode = FocusScopeNode();

    super.initState();
  }

  void _startSearching() {
    setState(() {
      _isSearching = true;
      _performSearch();
    });
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_redirectToSongScreen) {
      _redirectToSongScreen = false;
      Navigator.of(context).pushNamed(songScreenRoute, arguments: _video);
    }
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // When the user taps outside the TextField, stop searching
          _stopSearching();
          _focusScopeNode.unfocus();
        },
        child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/main_screen_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: _isSearching? MainAxisAlignment.start: MainAxisAlignment.center,
                children: [
                  if(_isLoadingSong) const CircularProgressIndicator(),
                  if(_isSearching) const SizedBox(height: 100),
                  if(!_isLoadingSong) searchBarWidget(),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: _isSearching,
                    child: searchBarResultsWidget()),
                  if(!_isSearching && !_isLoadingSong) ElevatedButton(
                    onPressed: () {
                      // TODO
                    },
                    child: const Text('Sazam'),
                  ),
                ],
              ),
            ),              
          ),
      ),
    );
  }

  Container searchBarWidget() {
    return Container(
      width: 300,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      alignment: Alignment.center,
      child: FocusScope(
        node: _focusScopeNode,
        child: TextField(
          controller: _textController,
          textAlignVertical: TextAlignVertical.center,
          onTap: () => _startSearching(),
          onChanged: (value) {
            _lastChangeTime = DateTime.now();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (DateTime.now().difference(_lastChangeTime) >= const Duration(milliseconds: 500)) {
                _performSearch();
              }
            });
          } ,
          decoration: InputDecoration(
            hintText: 'Search', 
            border: InputBorder.none,
            hintMaxLines: 1,
            prefixIcon: IconButton(
              onPressed: () {
                _performSearch();
              },
              icon: const Icon(Icons.search),
            ),
          ),
          onEditingComplete: () {
            _performSearch();
          },
          textInputAction: TextInputAction.search , 
        )
      ),
    );
  }

  Widget searchBarResultsWidget() {
  return Container(
    width: 300,
    height: 300,
    child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder(
                  stream: _searchResults,
                  builder: (context, snapshot) {
                  List<Video> results = snapshot.data ?? [];
                  if (snapshot.hasError) {
                    return const Text('Error');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting ) {
                    results = [];
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final Video result = results[index];
                      return Container(
                        width: 300,
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          leading: Image.network(result.thumbnails.mediumResUrl, width: 40, height: 40),
                          title: Text(
                            shringText(result.title, 24),
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () async {
                            setState(() {
                              _isSearching = false;
                              _isLoadingSong = true;
                            });

                            try{
                              _youTubeService.setVideoId( result.id.value);
                              
                              await _youTubeService.fetchVideo();
                              
                              setState(() {
                                _isSearching = true;
                                _isLoadingSong = false;
                                _redirectToSongScreen = true;
                                _video = result;               
                              });

                            }catch(e){
                              print("Errors: ");
                              print(e);
                            }
                                                        
                            setState(() {
                              _isSearching = true;
                              _isLoadingSong = false;
                            });
                          },
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  

  Future<void> _performSearch() async {
  String searchText = _textController.text;
  
  List<Video> results = await _youTubeService.search(searchText);
  _searchResultsController.add(results);
}

}
