import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding/data/raw/member_all_raw.dart';
import 'package:wedding/data/raw/signin_raw.dart';
import 'package:wedding/data/raw/token_raw.dart';
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
    return response.statusCode! > 300;
  }

  Future<MemberAllRaw> getAll() async {
    final response = await Api.getAllMembers();
    final data = MemberAllRaw.fromJson(response.data);
    return data;
  }
}
