class Group {
  final String groupName;
  final String userName;
  Group({required this.groupName, required this.userName});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupName: json['room_name'],
      userName: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_name': groupName,
      'username': userName,
    };
  }
  
}
