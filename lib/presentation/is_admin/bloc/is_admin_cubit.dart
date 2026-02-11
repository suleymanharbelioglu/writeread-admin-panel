import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/auth/usecase/is_admin.dart';
import 'package:writeread_admin_panel/domain/auth/usecase/signout.dart';
import 'package:writeread_admin_panel/presentation/is_admin/bloc/is_admin_state.dart';

class IsAdminCubit extends Cubit<IsAdminState> {
  IsAdminCubit({
    required IsAdminUseCase isAdminUseCase,
    required SignoutUseCase signoutUseCase,
  })  : _isAdminUseCase = isAdminUseCase,
        _signoutUseCase = signoutUseCase,
        super(IsAdminInitial());

  final IsAdminUseCase _isAdminUseCase;
  final SignoutUseCase _signoutUseCase;

  Future<void> checkAdmin() async {
    emit(IsAdminLoading());
    final result = await _isAdminUseCase.call();
    final isAdmin = result.fold((_) => false, (v) => v);
    if (isAdmin) {
      emit(IsAdminSuccess());
    } else {
      await _signoutUseCase.call();
      final message = result.fold((l) => l, (_) => 'You are not an admin.');
      emit(IsAdminNotAdmin(message: message));
    }
  }
}
