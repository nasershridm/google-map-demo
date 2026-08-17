import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dndn/core/theme/theme_cubit.dart';

class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return IconButton(
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: isDark ? Colors.amberAccent : theme.colorScheme.primary,
            ),
          ),
          onPressed: () {
            context.read<ThemeCubit>().toggleTheme();
          },
        );
      },
    );
  }
}
