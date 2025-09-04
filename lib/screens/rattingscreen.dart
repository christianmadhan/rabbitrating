import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RatingScreen extends StatefulWidget {
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
final List<String> _champions = [
  'Aatrox','Ahri','Akali','Akshan','Alistar','Amumu','Anivia','Annie',
  'Aphelios','Ashe','AurelionSol','Azir','Bard','Belveth','Blitzcrank',
  'Brand','Braum','Caitlyn','Camille','Cassiopeia','ChoGath','Corki',
  'Darius','Diana','DrMundo','Draven','Ekko','Elise','Evelynn','Ezreal',
  'Fiddlesticks','Fiora','Fizz','Galio','Gangplank','Garen','Gnar','Gragas',
  'Graves','Gwen','Hecarim','Heimerdinger','Illaoi','Irelia','Ivern','Janna',
  'JarvanIV','Jhin','Jinx','KaiSa','Karthus','Kassadin','Katarina','Kayle',
  'Kennen','KhaZix','Kled','KogMaw','KSante','Leblanc','LeeSin','Leona',
  'Lillia','Lissandra','Lucian','Lulu','Lux','Malphite','Malzahar','Maokai',
  'MissFortune','Milio','Mordekaiser','Morgana','Nami','Nasus','Nidalee','Nilah',
  'NunuWillump','Olaf','Orianna','Ornn','Pantheon','Poppy','Pyke','Qiyana',
  'Quinn','Rakan','Rammus','RekSai','RenataGlasc','Renekton','Rengar','Riven',
  'Ryze','Samira','Sejuani','Senna','Seraphine','Sett','Shaco','Shen','Sivir',
  'Skarner','Sona','Soraka','Swain','Sylas','Syndra','TahmKench','Taliyah',
  'Taric','Teemo','Thresh','Tristana','Trundle','Tryndamere','TwistedFate',
  'Twitch','Udyr','Urgot','Varus','Vayne','Veigar','VelKoz','Vex','Vi','Viego',
  'Viktor','Vladimir','Volibear','Warwick','Wukong','Xayah','Xerath','XinZhao',
  'Yasuo','Yone','Yorick','Yuumi','Zac','Zed','Zeri','Ziggs','Zilean','Zoe','Zyra'
];


int _currentIndex = 0;
double _rating = 0;
late Box<double> _ratingsBox;
late List<String> _remainingChampions;

@override
void initState() {
  super.initState();
  _ratingsBox = Hive.box<double>('ratings');

  // Copy the full champions list to a mutable list
  _remainingChampions = List.from(_champions);

  _pickRandomChampion();
}

// Pick a random champion from the remaining list
void _pickRandomChampion() {
  if (_remainingChampions.isEmpty) return;

  final random = Random();
  _currentIndex = random.nextInt(_remainingChampions.length);
}

void _submitRating() {
  if (_remainingChampions.isEmpty) return;

  String champion = _remainingChampions[_currentIndex];
  _ratingsBox.put(champion, _rating);

  setState(() {
    // Remove the rated champion
    _remainingChampions.removeAt(_currentIndex);
    _rating = 0;

    // Pick a new random champion if there are any left
    if (_remainingChampions.isNotEmpty) {
      _pickRandomChampion();
    }
  });
}

  @override
  Widget build(BuildContext context) {
    String currentChampion = _champions[_currentIndex];
    String imageUrl = 'https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${currentChampion}_0.jpg';

    return Scaffold(
      appBar: AppBar(title: Text('Rate Champion: $currentChampion')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(imageUrl, width: 500, height: 500, fit: BoxFit.cover)),
            SizedBox(height: 16),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRating,
              child: Text('Submit Rating'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RatingListScreen()),
                );
              },
              child: Text('View Ratings'),
            ),
          ],
        ),
      ),
    );
  }
}


class RatingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Ratings')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<double>('ratings').listenable(),
        builder: (context, Box<double> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No ratings yet.'));
          }

          List<String> championNames = box.keys.cast<String>().toList();
          return ListView.builder(
            itemCount: championNames.length,
            itemBuilder: (context, index) {
              String champion = championNames[index];
              double rating = box.get(champion) ?? 0;

              String imageUrl =
                  'https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${champion}_1.jpg';

              return ListTile(
                leading: Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
                title: Text(champion),
                subtitle: RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, _) =>
                      Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: Axis.horizontal,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Delete the rating from Hive
                    box.delete(champion);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$champion rating deleted')),
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