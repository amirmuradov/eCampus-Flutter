import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleModel {
  String weekDay;
  DateTime date;
  List<ScheduleLessonsModel> lessons;

  ScheduleModel({
    required this.weekDay,
    required this.date,
    required this.lessons,
  });
}

class ScheduleWeeksModel {
  String weekType, dateBegin, dateEnd, number;

  ScheduleWeeksModel(
      {required this.weekType,
      required this.dateBegin,
      required this.dateEnd,
      required this.number});

  DateTime getDateBegin() {
    return DateTime.parse(dateBegin);
  }

  DateTime getDateEnd() {
    return DateTime.parse(dateEnd);
  }

  String getStrDateBegin() {
    return DateFormat('MM.dd').format(getDateBegin());
  }

  String getStrDateEnd() {
    return DateFormat('MM.dd').format(getDateEnd());
  }
}

class ScheduleLessonsModel {
  String subName, room, teacher, lessonType, group;
  DateTime timeStart, timeEnd;
  int para, teacherId, roomId;
  bool current;

  ScheduleLessonsModel(
      {required this.subName,
      required this.room,
      required this.timeStart,
      required this.timeEnd,
      required this.teacher,
      required this.lessonType,
      required this.group,
      required this.para,
      required this.teacherId,
      required this.roomId,
      required this.current});

  String getTimeStart() {
    return "${timeStart.hour}:${timeStart.minute}";
  }

  String getTimeEnd() {
    return "${timeEnd.hour}:${timeEnd.minute}";
  }

  Widget getView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      para.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    lessonType,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    "${getTimeStart()}-${getTimeEnd()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            subName,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            teacher,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 7,
          ),
          Row(
            children: [
              Text(
                room,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                group,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
