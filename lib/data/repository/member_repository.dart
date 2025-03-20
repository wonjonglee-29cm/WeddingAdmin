import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding/data/raw/member_all_raw.dart';
import 'package:wedding/data/raw/signin_raw.dart';
import 'package:wedding/data/raw/token_raw.dart';
import 'package:wedding/data/raw/user_info_raw.dart';
import 'package:wedding/data/remote/api.dart';

class MemberRepository {
  final SharedPreferences _prefs;

  MemberRepository(this._prefs);

  Future<TokenRaw> signIn(SignInRaw request) async {
    final response = await Api.signIn(request);
    final signInResponse = TokenRaw.fromJson(response.data);

    await _prefs.setInt('id', signInResponse.id);
    await _prefs.setString('accessToken', signInResponse.accessToken);

    return signInResponse;
  }

  Future<bool> signUp(SignInRaw request) async {
    final response = await Api.signUp(request);
    return response.statusCode! <= 300;
  }

  Future<MemberAllRaw> getAll() async {
    final response = await Api.getAllMembers();
    final data = MemberAllRaw.fromJson(response.data);
    return data;
  }

  Future<UserInfoRaw> findMember(int id) async {
    final response = await Api.findMember(id);
    return UserInfoRaw.fromJson(response.data);
  }

  Future<UserInfoRaw> updateMember({
    required int id,
    required String name,
    required String guestType,
    required bool isAttendance,
    required bool isCompanion,
    required int? companionCount,
    required bool isMeal,
  }) async {
    final request = UserInfoRaw(
      id: id,
      name: name,
      guestType: guestType,
      isAttendance: isAttendance,
      isCompanion: isCompanion,
      companionCount: companionCount,
      isMeal: isMeal,
    );

    final response = await Api.updateMember(request);
    final info = UserInfoRaw.fromJson(response.data);

    return info;
  }
}
