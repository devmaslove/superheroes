import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  final http.Client? client;

  MainPage({Key? key, this.client}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc(client: widget.client);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatelessWidget {
  final FocusNode search = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainPageStateWidget(focusNode: search),
        Padding(
          padding: const EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
          ),
          child: SearchWidget(focusNode: search),
        ),
      ],
    );
  }
}

class SearchWidget extends StatefulWidget {
  final FocusNode? focusNode;

  const SearchWidget({
    Key? key,
    this.focusNode,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController controller = TextEditingController();
  bool _haveSearchedText = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
      controller.addListener(() {
        bloc.updateText(controller.text);
        final haveText = controller.text.isNotEmpty;
        if (_haveSearchedText != haveText)
          setState(() {
            _haveSearchedText = haveText;
          });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: widget.focusNode,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: SuperheroesColors.indigo75,
        prefixIcon: Icon(
          Icons.search,
          color: Colors.white54,
          size: 24,
        ),
        suffix: GestureDetector(
          onTap: () => controller.clear(),
          child: Icon(
            Icons.clear,
            color: Colors.white,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _haveSearchedText ? Colors.white : Colors.white24,
            width: _haveSearchedText ? 2 : 1,
          ),
        ),
      ),
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  final FocusNode? focusNode;

  const MainPageStateWidget({Key? key, this.focusNode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return LoadingIndicator();
          case MainPageState.minSymbols:
            return MinSymbolsWidget();
          case MainPageState.noFavorites:
            return NoFavoritesWidget(focusNode: focusNode);
          case MainPageState.nothingFound:
            return InfoWithButton(
              title: "Nothing found",
              subtitle: "Search for something else",
              buttonText: "Search",
              assetImage: SuperheroesImages.hulk,
              imageHeight: 112,
              imageWidth: 84,
              imageTopPadding: 16,
              onTap: () => focusNode?.requestFocus(),
            );
          case MainPageState.loadingError:
            return InfoWithButton(
              title: "Error happened",
              subtitle: "Please, try again",
              buttonText: "Retry",
              assetImage: SuperheroesImages.superMan,
              imageHeight: 106,
              imageWidth: 126,
              imageTopPadding: 22,
              onTap: () => {},
            );
          case MainPageState.favorites:
            return FavoritesWidget();
          case MainPageState.searchResults:
            return SuperheroesList(
              title: "Search results",
              stream: bloc.observeSearchedSuperheroes(),
            );
          default:
            return Center(
              child: Text(
                state.toString(),
                style: TextStyle(color: Colors.white),
              ),
            );
        }
      },
    );
  }
}

class FavoritesWidget extends StatelessWidget {
  const FavoritesWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return Stack(
      children: [
        SuperheroesList(
          title: "Your favorites",
          stream: bloc.observeFavoriteSuperheroes(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ActionButton(
            onTap: () => bloc.removeFavorite(),
            text: "Remove",
          ),
        ),
      ],
    );
  }
}

class NoFavoritesWidget extends StatelessWidget {
  final FocusNode? focusNode;

  const NoFavoritesWidget({
    Key? key,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return Stack(
      children: [
        InfoWithButton(
          title: "No favorites yet",
          subtitle: "Search and add",
          buttonText: "Search",
          assetImage: SuperheroesImages.ironMan,
          imageHeight: 119,
          imageWidth: 108,
          imageTopPadding: 9,
          onTap: () => focusNode?.requestFocus(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ActionButton(
            onTap: () => bloc.removeFavorite(),
            text: "Remove",
          ),
        ),
      ],
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;

  const SuperheroesList({Key? key, required this.title, required this.stream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuperheroInfo>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final List<SuperheroInfo> superheroes = snapshot.data!;
          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: superheroes.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 90, bottom: 12),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      height: 1.375,
                    ),
                  ),
                );
              }
              final SuperheroInfo item = superheroes[index - 1];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SuperheroCard(
                  superheroInfo: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SuperheroPage(title: item.name),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 8);
            },
          );
        });
  }
}

class MinSymbolsWidget extends StatelessWidget {
  const MinSymbolsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: Text(
          "Enter at least 3 symbols",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          color: SuperheroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}
