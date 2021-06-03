import 'dart:io';

import 'package:deluge_client/components/all_acc.dart';
import 'package:deluge_client/components/all_info.dart';
import 'package:deluge_client/components/download_upload_pane.dart';
import 'package:deluge_client/components/progress_bar.dart';
import 'package:deluge_client/database/dbmanager.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:deluge_client/control_center/theme.dart';
import 'package:deluge_client/api/apis.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class tile extends StatefulWidget {
  final multtorrent hash_m;
  final bool for_multi;
  final List<String> selected_torrents;
  final List<multtorrent> multi_selected_torrent;
  final String hash;
  final Map<String, dynamic> inside_res;
  final bool paused;
  final bool seeding;
  final Bucket selx_acc;
  final List<Cookie> cookie;
  bool completed;
  final VoidCallback non_delayed_fetch;
  tile(
      {Key key,
      this.selected_torrents,
      this.cookie,
      this.paused,
      this.seeding,
      this.selx_acc,
      this.hash,
      this.multi_selected_torrent,
      this.for_multi,
      this.inside_res,
      this.hash_m,
      this.completed,
      this.non_delayed_fetch})
      : super(key: key);

  @override
  _tileState createState() => _tileState(
      cookie: cookie,
      hash: hash,
      multi_selected_torrent: multi_selected_torrent,
      paused: paused,
      seeding: seeding,
      selected_torrents: selected_torrents,
      selx_acc: selx_acc,
      inside_res: inside_res,
      for_multi: for_multi,
      hashm: hash_m,
      completed: completed,
      non_delayed_fetch: non_delayed_fetch);
}

class _tileState extends State<tile> {
  final List<String> selected_torrents;
  final List<multtorrent> multi_selected_torrent;
  final String hash;
  final bool paused;
  final bool seeding;
  final bool for_multi;
  final Bucket selx_acc;
  final List<Cookie> cookie;
  final Map<String, dynamic> inside_res;
  final multtorrent hashm;
  bool completed;
  final VoidCallback non_delayed_fetch;

  _tileState(
      {this.selected_torrents,
      this.cookie,
      this.paused,
      this.seeding,
      this.selx_acc,
      this.hash,
      this.for_multi,
      this.multi_selected_torrent,
      this.inside_res,
      this.hashm,
      this.completed,
      this.non_delayed_fetch});
  //-------------------------------------------------delete and pause operations for solo
  void pause() {
    apis.pause_activity(
        hash,
        cookie,
        selx_acc.deluge_url,
        selx_acc.is_reverse_proxied,
        selx_acc.username,
        selx_acc.password,
        selx_acc.via_qr);
    non_delayed_fetch();
  }

  void resume() {
    apis.resume_activity(
        hash,
        cookie,
        selx_acc.deluge_url,
        selx_acc.is_reverse_proxied,
        selx_acc.username,
        selx_acc.password,
        selx_acc.via_qr);
    non_delayed_fetch();
  }

  //--------------------------
  void delete_torrent(BuildContext context) {
    /** intuition:-
     * first i will prompt user to "are you sure to delete selected torrents"
     * second i will prompt user to "do you also wanted to delete downloaded data"
     * <--
     * implement logics to solve problem
     * -->
     * 
     * **/

    showAlertDialog_prompt1(context);
  }

  showAlertDialog_prompt1(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "No",
        style: TextStyle(
            color: Colors.blue,
            fontSize: theme.alert_box_font_size,
            fontWeight: FontWeight.bold,
            fontFamily: theme.font_family),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Yes",
        style: TextStyle(
            color: Colors.white,
            fontSize: theme.alert_box_font_size,
            fontWeight: FontWeight.bold,
            fontFamily: theme.font_family),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        showAlertDialog_prompt2(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: theme.base_color,
      title: Text("Pay Attention",
          style: TextStyle(color: Colors.white, fontFamily: theme.font_family)),
      content: Text(
        "Are you sure to delete selected torrents",
        style: TextStyle(
            fontSize: theme.alert_box_font_size,
            color: Colors.white,
            fontFamily: theme.font_family),
      ),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //------------
  showAlertDialog_prompt2(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Yes",
        style: TextStyle(
            color: Colors.white,
            fontSize: theme.alert_box_font_size,
            fontWeight: FontWeight.bold,
            fontFamily: theme.font_family),
      ),
      onPressed: () {
        apis.delete_activity(
            cookie,
            hash,
            true,
            selx_acc.deluge_url,
            selx_acc.is_reverse_proxied,
            selx_acc.username,
            selx_acc.password,
            selx_acc.via_qr);

        non_delayed_fetch();

        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "No",
        style: TextStyle(
            color: Colors.blue,
            fontSize: theme.alert_box_font_size,
            fontWeight: FontWeight.bold,
            fontFamily: theme.font_family),
      ),
      onPressed: () {
        apis.delete_activity(
            cookie,
            hash,
            false,
            selx_acc.deluge_url,
            selx_acc.is_reverse_proxied,
            selx_acc.username,
            selx_acc.password,
            selx_acc.via_qr);

        non_delayed_fetch();

        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: theme.base_color,
      title: Text("Pay Attention",
          style: TextStyle(color: Colors.white, fontFamily: theme.font_family)),
      content: Text(
        "Are you also wanted to delete downloaded data",
        style: TextStyle(
            fontSize: theme.alert_box_font_size,
            color: Colors.white,
            fontFamily: theme.font_family),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void update_completion_state(bool val) {
    if (this.mounted) {
      setState(() {
        completed = val;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            color: (!for_multi
                    ? selected_torrents.contains(hash)
                    : multi_selected_torrent.contains(hashm))
                ? Colors.blueGrey
                : Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        inside_res['name'],
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: theme.font_family),
                      ),
                    ],
                  ),
                ),
                //2nd row
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Total Size: " +
                            (inside_res['total_size'] ~/ 1000000).toString() +
                            " MB",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: theme.minimal_font_size,
                            fontFamily: theme.font_family),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: completed
                            ? Icon(Icons.download_done_outlined)
                            : Container(height: 0.0, width: 0.0),
                      ),
                      Flexible(
                          fit: FlexFit.tight,
                          child: !paused
                              ? seeding
                                  ? Text("seeding")
                                  : Text("")
                              : Text("")),
                      Container(
                        padding: EdgeInsets.only(left: 15.0),
                        child: network_speed(
                          torrent_id: hash,
                          cookie: cookie,
                          tor_name: inside_res['name'],
                          url: selx_acc.deluge_url,
                          is_reverse_proxied: selx_acc.is_reverse_proxied,
                          seed_username: selx_acc.username,
                          seed_pass: selx_acc.password,
                          qr_auth: selx_acc.via_qr,
                          paused: paused,
                          completed: completed,
                        ),
                      )
                    ],
                  ),
                ),
                //----------
                //network speed

                //download info

                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      download_progress(
                        torrent_id: hash,
                        initial_progress: inside_res['progress'],
                        cookie: cookie,
                        tor_name: inside_res['name'],
                        url: selx_acc.deluge_url,
                        is_reverse_proxied: selx_acc.is_reverse_proxied,
                        seed_username: selx_acc.username,
                        seed_pass: selx_acc.password,
                        qr_auth: selx_acc.via_qr,
                        paused: paused,
                        update_completion_state: (bool val) {
                          update_completion_state(val);
                        },
                        completed: completed,
                      ),
                      RawMaterialButton(
                        onPressed: () {
                          
                            if (paused) {
                              resume();
                            } else {
                              pause();
                            }
                          
                        },
                        elevation: 2.0,
                        fillColor: theme.base_color,
                        child: paused
                            ? Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 20.0,
                              )
                            : Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: 20.0,
                              ),
                        padding: EdgeInsets.all(10.0),
                        shape: CircleBorder(),
                      ),
                    ],
                  ),
                ),
                ExpandableTheme(
                    child: more_info(inside_res: inside_res, paused: paused),
                    data: const ExpandableThemeData(
                      iconColor: Colors.blue,
                      useInkWell: true,
                    )),

                Divider(
                  color: theme.base_color,
                  height: 10.0,
                  thickness: 5.0,
                )
              ],
            )),
        secondaryActions: <Widget>[
          IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                delete_torrent(context);
              }),
        ]);
  }
}