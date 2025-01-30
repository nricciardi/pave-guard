import 'package:admin/controllers/menu_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              //color: const Color.fromARGB(222, 220, 220, 211),
            ),
            child: Center(
              child: Text(
                'PaveGuard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  /*
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: <Color>[Colors.blue, Colors.purple],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    */
                ),
              ),
            ),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              Provider.of<MenuAppController>(context, listen: false)
                  .setScreen(MenuState.dashboard);
            },
          ),
          DrawerListTile(
            title: "Statistics",
            svgSrc: "assets/icons/statistics.svg",
            press: () {
              Provider.of<MenuAppController>(context, listen: false)
                  .setScreen(MenuState.statistics);
            },
          ),
          DrawerListTile(
            title: "Planning",
            svgSrc: "assets/icons/planning.svg",
            press: () {
              Provider.of<MenuAppController>(context, listen: false)
                  .setScreen(MenuState.planning);
            },
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/profile.svg",
            press: () {
              Provider.of<MenuAppController>(context, listen: false)
                  .setScreen(MenuState.profile);
            },
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/settings.svg",
            press: () {
              Provider.of<MenuAppController>(context, listen: false)
                  .setScreen(MenuState.settings);
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
