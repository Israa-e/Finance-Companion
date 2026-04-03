import 'package:equatable/equatable.dart';

enum SplashStatus { initial, animating, completed }

class SplashState extends Equatable {
  final SplashStatus status;

  const SplashState({required this.status});

  factory SplashState.initial() => const SplashState(status: SplashStatus.initial);

  SplashState copyWith({SplashStatus? status}) {
    return SplashState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}
