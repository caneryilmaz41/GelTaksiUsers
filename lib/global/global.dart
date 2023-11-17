import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_app/models/user_%20model.dart';

import '../models/direction_detail_info.dart';

final FirebaseAuth fAuth=FirebaseAuth.instance;
User? currenFirebaseUser;
UserModel? userModelCurrentInfo;
List dList=[];//online sürücünün bilgi listesi
DirectionDetailsInfo? tripDirectiondetailsInfo;