import 'package:flutter/material.dart';
import 'package:sazamtomp3/helpers/shrink_text.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  TextEditingController _textController = TextEditingController();
  FocusScopeNode _focusScopeNode = FocusScopeNode();

  bool _isSearching = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  void _startSearching() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  if(_isSearching) const SizedBox(height: 100),
                  searchBarWidget(),
                  if(_isSearching) searchBarResultsWidget(),
                  if(!_isSearching) ElevatedButton(
                    onPressed: () {
                      
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
    List<Map<String,dynamic>> results = [{
      'title': 'Title 1',
      'thumbnail': 'https://picsum.photos/250?image=9',
    }, {
      'title': 'Title 2',
      'thumbnail': 'https://picsum.photos/250?image=9',
    }, {
      'title': 'Title 3',
      'thumbnail': 'https://picsum.photos/250?image=9',
    }];

    return Column(
      children: [
        const SizedBox(height: 10),
        for (var result in results) Container(
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
            leading: Image.network(result['thumbnail'], width: 40, height: 40,),
            title: Text(shringText(result['title'], 24) , style: const TextStyle(fontSize: 16),),  
            onTap: () {
              print('Tapped on ${result['title']}');
            },
          ),
        )

      ],
    );
  }
  

  void _performSearch() {
    String searchText = _textController.text;
    print('Search Text: $searchText');
    // Perform your search logic here
  }
}
