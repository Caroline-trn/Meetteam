import 'package:flutter/material.dart';
import 'package:meetteam/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  late String _userName;
  int _selectedIndex = 0;
  bool _isSidebarExpanded = false;
  int _hoveredIndex = -1;
  bool _isMobile = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showMoreMenu = false;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _loadUserData();
    
    Future.delayed(Duration(seconds: 3), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF2C2C2C),
            title: Text("Notification", style: TextStyle(color: Colors.white)),
            content: Text("Votre réunion de 9h30 va commencer dans 5 minutes !", 
                         style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                child: Text("OK", style: TextStyle(color: Color(0xFFE67E22))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _loadUserData() async {
    setState(() {
      _userName = widget.userName;
    });
  }

  void _logout() async {
    bool success = await _authService.logout();
    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la déconnexion"),
          backgroundColor: Color(0xFFE67E22),
        ),
      );
    }
  }

  void _inviteToJoin() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2C2C2C),
          title: Text("Inviter à rejoindre Meetteam", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Partagez ce lien pour inviter des collègues:", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF444444),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "https://meetteam.app/invite/${_userName.toLowerCase()}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              Text("Ou copiez le lien:", style: TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Annuler", style: TextStyle(color: Color(0xFFE67E22))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Lien d'invitation copié !"),
                    backgroundColor: Color(0xFFE67E22),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE67E22),
              ),
              child: Text("Copier le lien"),
            ),
          ],
        );
      },
    );
  }

  void _showMoreOptionsMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(button.size.width, 0), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset(button.size.width, 50)), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Color(0xFF333333),
      items: [
        PopupMenuItem(
          value: 4,
          child: ListTile(
            leading: Icon(Icons.note, color: Colors.white70),
            title: Text('Notes', style: TextStyle(color: Colors.white)),
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: ListTile(
            leading: Icon(Icons.bar_chart, color: Colors.white70),
            title: Text('Rapports', style: TextStyle(color: Colors.white)),
          ),
        ),
        PopupMenuItem(
          value: 6,
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.white70),
            title: Text('Calendrier', style: TextStyle(color: Colors.white)),
          ),
        ),
        PopupMenuItem(
          value: 7,
          child: ListTile(
            leading: Icon(Icons.settings, color: Colors.white70),
            title: Text('Paramètres', style: TextStyle(color: Colors.white)),
          ),
        ),
        PopupMenuItem(
          value: 8,
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.white70),
            title: Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
      elevation: 8,
    ).then((value) {
      if (value != null) {
        if (value == 8) {
          _logout();
        } else {
          setState(() {
            _selectedIndex = value;
          });
        }
      }
    });
  }

  Widget _buildSidebarItem(int index, IconData icon, String text) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (index == 8) {
            _logout();
          } else {
            setState(() {
              _selectedIndex = index;
            });
            if (_isMobile) {
              _scaffoldKey.currentState?.openEndDrawer();
            }
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: _isSidebarExpanded ? 20 : 0),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _selectedIndex == index
                ? Color(0xFFE67E22).withOpacity(0.2)
                : _hoveredIndex == index
                  ? Color(0xFFE67E22).withOpacity(0.1)
                  : Colors.transparent,
            border: _selectedIndex == index
                ? Border.all(color: Color(0xFFE67E22).withOpacity(0.5), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: _isSidebarExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: _selectedIndex == index || _hoveredIndex == index
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF444444), Color(0xFF222222)],
                        ),
                  boxShadow: _selectedIndex == index || _hoveredIndex == index
                      ? [
                          BoxShadow(
                            color: Color(0xFFE67E22).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  icon,
                  color: _selectedIndex == index || _hoveredIndex == index 
                      ? Colors.white 
                      : Color(0xFFCCCCCC),
                  size: 18,
                ),
              ),
              if (_isSidebarExpanded) SizedBox(width: 15),
              if (_isSidebarExpanded)
                AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: _isSidebarExpanded ? 1 : 0,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: _selectedIndex == index || _hoveredIndex == index
                          ? Color(0xFFE67E22)
                          : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String link) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _isMobile ? 18 : 20,
            color: Color(0xFFECF0F1),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (link.isNotEmpty)
          TextButton(
            onPressed: () {},
            child: Text(
              link,
              style: TextStyle(
                color: Color(0xFFE67E22),
                fontSize: _isMobile ? 12 : 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMeetingCard() {
    return Container(
      padding: EdgeInsets.all(_isMobile ? 15 : 20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMeetingItem("09:30", "Révision du projet Phoenix", "Avec l'équipe Marketing", "En ligne", true),
          Divider(color: Color(0xFF4A4A4A), height: 20),
          _buildMeetingItem("14:00", "Présentation des nouveaux produits", "Avec les équipes Design et Dev", "En présentiel", false),
          Divider(color: Color(0xFF4A4A4A), height: 20),
          _buildMeetingItem("16:30", "Point hebdomadaire", "Avec toute l'équipe", "En ligne", true),
        ],
      ),
    );
  }

  Widget _buildMeetingItem(String time, String title, String participants, String badgeText, bool isOnline) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFE67E22).withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: Color(0xFFE67E22),
                fontWeight: FontWeight.w600,
                fontSize: _isMobile ? 12 : 14,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFFECF0F1),
                    fontWeight: FontWeight.w600,
                    fontSize: _isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  participants,
                  style: TextStyle(
                    color: Color(0xFFBDC3C7),
                    fontSize: _isMobile ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline ? Color(0xFFE67E22) : Color(0xFFF39C12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: isOnline ? Colors.white : Color(0xFF1E1E1E),
                fontSize: _isMobile ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: EdgeInsets.all(_isMobile ? 15 : 20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActivityItem("MD", "Marie Dubois a partagé un document", "Rapport_trimestriel_Q3.pdf", "Il y a 15 minutes"),
          Divider(color: Color(0xFF4A4A4A), height: 20),
          _buildActivityItem("PL", "Pierre Laurent a commenté votre note", "\"J'ai ajouté quelques suggestions pour la présentation...\"", "Il y a 2 heures"),
          Divider(color: Color(0xFF4A4A4A), height: 20),
          _buildActivityItem("ES", "Équipe Support a résolu un ticket", "Ticket #4572 - Problème de connexion", "Hier, 16:45"),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String avatar, String title, String description, String time) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _isMobile ? 35 : 40,
            height: _isMobile ? 35 : 40,
            decoration: BoxDecoration(
              color: Color(0xFFE67E22),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: _isMobile ? 12 : 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFFECF0F1),
                    fontWeight: FontWeight.w600,
                    fontSize: _isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: Color(0xFFBDC3C7),
                    fontSize: _isMobile ? 12 : 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: _isMobile ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCards() {
    if (_isMobile) {
      return Column(
        children: [
          _buildFeatureCard(
            Icons.note,
            "Notes de réunion",
            "Prenez des notes collaboratives pendant vos réunions et partagez-les avec les participants.",
          ),
          SizedBox(height: 20),
          _buildFeatureCard(
            Icons.description,
            "Rapports",
            "Rédigez et envoyez vos rapports hebdomadaires à votre supérieur directement depuis la plateforme.",
          ),
          SizedBox(height: 20),
          _buildFeatureCard(
            Icons.chat,
            "Messages directs",
            "Communiquez en temps réel avec vos collègues via le chat individuel ou de groupe.",
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              Icons.note,
              "Notes de réunion",
              "Prenez des notes collaboratives pendant vos réunions et partagez-les avec les participants.",
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildFeatureCard(
              Icons.description,
              "Rapports",
              "Rédigez et envoyez vos rapports hebdomadaires à votre supérieur directement depuis la plateforme.",
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildFeatureCard(
              Icons.chat,
              "Messages directs",
              "Communiquez en temps réel avec vos collègues via le chat individuel ou de groupe.",
            ),
          ),
        ],
      );
    }
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: EdgeInsets.all(_isMobile ? 15 : 20),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
          border: Border(left: BorderSide(color: Color(0xFFE67E22), width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: _isMobile ? 35 : 40,
                  height: _isMobile ? 35 : 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFE67E22).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFFE67E22),
                    size: _isMobile ? 18 : 24,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFFECF0F1),
                      fontSize: _isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              description,
              style: TextStyle(
                color: Color(0xFFECF0F1),
                fontSize: _isMobile ? 13 : 14,
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              child: Text("Ouvrir"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE67E22),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCards() {
    if (_isMobile) {
      return Column(
        children: [
          _buildNoteCard(
            "Idées pour la réunion marketing",
            "Présenter les nouvelles statistiques d'engagement. Préparer un plan pour Q4.",
            "Modifié: 12 Oct",
            true,
          ),
          SizedBox(height: 20),
          _buildNoteCard(
            "Points à aborder avec l'équipe technique",
            "Discuter des délais de livraison. Nouveaux besoins en infrastructure.",
            "Modifié: 10 Oct",
            false,
          ),
          SizedBox(height: 20),
          _buildNoteCard(
            "Compte-rendu réunion client",
            "Le client a validé les maquettes. Prévoir une nouvelle démo le 25 octobre.",
            "Modifié: 8 Oct",
            true,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buildNoteCard(
              "Idées pour la réunion marketing",
              "Présenter les nouvelles statistiques d'engagement. Préparer un plan pour Q4.",
              "Modifié: 12 Oct",
              true,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildNoteCard(
              "Points à aborder avec l'équipe technique",
              "Discuter des délais de livraison. Nouveaux besoins en infrastructure.",
              "Modifié: 10 Oct",
              false,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildNoteCard(
              "Compte-rendu réunion client",
              "Le client a validé les maquettes. Prévoir une nouvelle démo le 25 octobre.",
              "Modifié: 8 Oct",
              true,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNoteCard(String title, String content, String date, bool isShared) {
    return Container(
      padding: EdgeInsets.all(_isMobile ? 12 : 15),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
        border: Border(left: BorderSide(color: Color(0xFFE67E22), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFFECF0F1),
              fontWeight: FontWeight.w600,
              fontSize: _isMobile ? 14 : 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: Color(0xFFECF0F1),
              fontSize: _isMobile ? 13 : 14,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: _isMobile ? 11 : 12,
                ),
              ),
              Icon(
                isShared ? Icons.group : Icons.lock,
                color: Color(0xFF7F8C8D),
                size: _isMobile ? 14 : 16,
              ),
            ],
          ),
        ],
     ) );
  }

  Widget _buildMobileBottomNav() {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF333333),
      selectedItemColor: Color(0xFFE67E22),
      unselectedItemColor: Color(0xFFCCCCCC),
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == 4) {
          _showMoreOptionsMenu(context);
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_call),
          label: 'Réunions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Communauté',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'Plus',
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _isMobile ? MediaQuery.of(context).size.width * 0.7 : 250,
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40, bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFE67E22).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  "Meetteam",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              children: [
                _buildSidebarItem(0, Icons.home, "Accueil"),
                _buildSidebarItem(1, Icons.chat, "Messages"),
                _buildSidebarItem(2, Icons.video_call, "Réunions"),
                _buildSidebarItem(3, Icons.group, "Communautés"),
                _buildSidebarItem(4, Icons.note, "Notes"),
                _buildSidebarItem(5, Icons.bar_chart, "Rapports"),
                _buildSidebarItem(6, Icons.calendar_today, "Calendrier"),
                _buildSidebarItem(7, Icons.settings, "Paramètres"),
                _buildSidebarItem(8, Icons.logout, "Déconnexion"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _isMobile = mediaQuery.size.width < 768;

    if (_isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text(
            "Meetteam",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu, color: Color(0xFFECF0F1)),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Color(0xFFECF0F1)),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: Color(0xFFECF0F1)),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person_add_alt_1, color: Color(0xFFECF0F1)),
              onPressed: _inviteToJoin,
              tooltip: "Inviter à rejoindre Meetteam",
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Color(0xFF333333),
          child: _buildSidebar(),
        ),
        body: Container(
          color: Color(0xFF1E1E1E),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF333333), Color(0xFF795548)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bonjour, $_userName",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Bienvenue sur votre espace personnel",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Vous avez 2 réunions aujourd'hui et 3 messages non lus. Restez connecté avec votre équipe !",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                _buildSectionTitle("Réunions du jour", "Voir tout"),
                SizedBox(height: 15),
                _buildMeetingCard(),
                
                SizedBox(height: 20),
                
                _buildSectionTitle("Activité récente", "Voir tout"),
                SizedBox(height: 15),
                _buildActivityCard(),
                
                SizedBox(height: 20),
                
                _buildSectionTitle("Outils de collaboration", ""),
                SizedBox(height: 15),
                _buildFeaturesCards(),
                
                SizedBox(height: 20),
                
                _buildSectionTitle("Mes notes récentes", "Voir tout"),
                SizedBox(height: 15),
                _buildNotesCards(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildMobileBottomNav(),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar Desktop
            MouseRegion(
              onEnter: (_) => setState(() => _isSidebarExpanded = true),
              onExit: (_) => setState(() {
                _isSidebarExpanded = false;
                _hoveredIndex = -1;
              }),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isSidebarExpanded ? 250 : 80,
                decoration: BoxDecoration(
                  color: Color(0xFF333333),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 30),
                      child: Row(
                        mainAxisAlignment: _isSidebarExpanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          if (_isSidebarExpanded) SizedBox(width: 20),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFE67E22).withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          if (_isSidebarExpanded) SizedBox(width: 15),
                          if (_isSidebarExpanded)
                            Text(
                              "Meetteam",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: ListView(
                        children: [
                          _buildSidebarItem(0, Icons.home, "Accueil"),
                          _buildSidebarItem(1, Icons.chat, "Messages"),
                          _buildSidebarItem(2, Icons.video_call, "Réunions"),
                          _buildSidebarItem(3, Icons.group, "Communautés"),
                          _buildSidebarItem(4, Icons.note, "Notes"),
                          _buildSidebarItem(5, Icons.bar_chart, "Rapports"),
                          _buildSidebarItem(6, Icons.calendar_today, "Calendrier"),
                          _buildSidebarItem(7, Icons.settings, "Paramètres"),
                          _buildSidebarItem(8, Icons.logout, "Déconnexion"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Main content
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.menu, color: Color(0xFFECF0F1)),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Rechercher...",
                                hintStyle: TextStyle(color: Color(0xFFBDC3C7)),
                                filled: true,
                                fillColor: Color(0xFF2C2C2C),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Color(0xFF4A4A4A)),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                prefixIcon: Icon(Icons.search, color: Color(0xFFBDC3C7)),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications, color: Color(0xFFECF0F1)),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.help, color: Color(0xFFECF0F1)),
                          onPressed: () {},
                        ),
                        TextButton.icon(
                          onPressed: _inviteToJoin,
                          icon: Icon(Icons.person_add_alt_1, size: 18, color: Colors.white),
                          label: Text(
                            "Inviter à rejoindre",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFE67E22),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFE67E22),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE67E22).withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _userName.isNotEmpty 
                                ? _userName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase()
                                : "US",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: Container(
                      color: Color(0xFF1E1E1E),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF333333), Color(0xFF795548)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bonjour, $_userName",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Bienvenue sur votre espace personnel",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Vous avez 2 réunions aujourd'hui et 3 messages non lus. Restez connecté avec votre équipe !",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 30),
                            
                            // Meetings Section
                            _buildSectionTitle("Réunions du jour", "Voir tout"),
                            SizedBox(height: 20),
                            _buildMeetingCard(),
                            
                            SizedBox(height: 30),
                            
                            // Recent Activity
                            _buildSectionTitle("Activité récente", "Voir tout"),
                            SizedBox(height: 20),
                            _buildActivityCard(),
                            
                            SizedBox(height: 30),
                            
                            // Features Cards
                            _buildSectionTitle("Outils de collaboration", ""),
                            SizedBox(height: 20),
                            _buildFeaturesCards(),
                            
                            SizedBox(height: 30),
                            
                            // Notes Section
                            _buildSectionTitle("Mes notes récentes", "Voir tout"),
                            SizedBox(height: 20),
                            _buildNotesCards(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}