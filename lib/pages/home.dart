import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/pages/chatpage.dart';
import 'package:messagingapp/service/database.dart';
import 'package:messagingapp/service/shared.pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  Stream? chatRoomsStream;

  getthesharedpref() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    setState(() {});
  }

  ontheload() async {
    //whenever user comes to homepage , then app calls getsharedpref and gives personal details
    await getthesharedpref();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget ChatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    print(ds.id);
                    return ChatRoomListTile(
                        chatRoomId: ds.id,
                        lastMessage: ds["lastMessage"],
                        myUsername: myUserName!,
                        time: ds["lastMessageSendTs"]);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  var queryResultSet = [];
  var tempSearchStore = [];

  void initiateSearch(value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    } else {
      final capitalizedValue =
          '${value.substring(0, 1).toUpperCase()}${value.substring(1)}';

      setState(() {
        search = true;
      });

      if (queryResultSet.isEmpty && value.length == 1) {
        DatabaseMethods().Search(value).then((QuerySnapshot docs) {
          for (int i = 0; i < docs.docs.length; ++i) {
            queryResultSet.add(docs.docs[i].data());
          }
        });
      } else {
        tempSearchStore = [];
        queryResultSet.forEach((element) {
          if (element['username'].startsWith(capitalizedValue)) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 215, 115),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 50.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  search
                      ? Expanded(
                          child: TextField(
                          onChanged: (value) {
                            initiateSearch(value.toUpperCase());
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search Users',
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500)),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500),
                        ))
                      : Text(
                          "Srub",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.w600,
                              fontSize: 22.0),
                        ),
                  GestureDetector(
                    onTap: () {
                      search = true;
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: search
                          ? GestureDetector(
                              onTap: () {
                                search = false;
                                setState(() {});
                              },
                              child: Icon(
                                Icons.close,
                                color: Color(0Xffc199cd),
                              ),
                            )
                          : Icon(
                              Icons.search,
                              color: Color.fromARGB(255, 29, 121, 78),
                            ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              width: MediaQuery.of(context).size.width,
              height: search
                  ? MediaQuery.of(context).size.height / 1.2
                  : MediaQuery.of(context).size.height / 1.15,
              decoration: BoxDecoration(
                color: Color.fromARGB(231, 34, 33, 36),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  search
                      ? ListView(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          primary: false,
                          shrinkWrap: true,
                          children: tempSearchStore.map((element) {
                            return buildResultCard(element);
                          }).toList())
                      : ChatRoomList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        setState(() {});

        var chatRoomId = getChatRoomIdbyUsername(myUserName!, data["username"]);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data["username"]]
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: data["Name"],
                    profileurl: data["Photo"],
                    username: data["username"])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    data["Photo"],
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      data["username"],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;
  ChatRoomListTile(
      {required this.chatRoomId,
      required this.lastMessage,
      required this.myUsername,
      required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "", id = "";

  getthisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    final querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());

    if (querySnapshot.docs.isNotEmpty) {
      final firstDoc = querySnapshot.docs.first;
      name = firstDoc["Name"] as String;
      profilePicUrl = firstDoc["Photo"] as String;
      id = firstDoc["Id"] as String;
      setState(() {});
    }
  }

  @override
  void initState() {
    getthisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: name,
                    profileurl: profilePicUrl,
                    username: username)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicUrl == ""
                ? CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      profilePicUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    )),
            SizedBox(
              width: 10.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  username,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 17.0,
                      fontWeight: FontWeight.w500),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(
                    widget.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              widget.time,
              style: TextStyle(
                  color: const Color.fromARGB(115, 255, 255, 255),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
