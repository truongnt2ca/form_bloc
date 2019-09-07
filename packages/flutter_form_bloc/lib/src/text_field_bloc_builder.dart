import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/src/flutter_typeahead.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:flutter/widgets.dart';

export 'package:flutter/services.dart'
    show TextInputType, TextInputAction, TextCapitalization;

export 'package:flutter_form_bloc/src/flutter_typeahead.dart'
    show SuggestionsBoxDecoration;

const double _kMenuItemHeight = 48.0;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 16.0);

enum SuffixButton { obscureText, clearText }

typedef TextFieldBlocErrorBuilder<Error> = String Function(
  BuildContext context,
  Error error,
);

class TextFieldBlocBuilder<Error> extends StatefulWidget {
  /// Creates a Material Design text field with a TextFieldBloc
  ///
  ///
  ///
  ///
  ///
  /// If [decoration] is non-null (which is the default), the text field requires
  /// one of its ancestors to be a [Material] widget.
  ///
  /// To remove the decoration entirely (including the extra padding introduced
  /// by the decoration to save space for the labels), set the [decoration] to
  /// null.
  ///
  /// The [maxLines] property can be set to null to remove the restriction on
  /// the number of lines. By default, it is one, meaning this is a single-line
  /// text field. [maxLines] must not be zero.
  ///
  /// The [maxLength] property is set to null by default, which means the
  /// number of characters allowed in the text field is not restricted. If
  /// [maxLength] is set a character counter will be displayed below the
  /// field showing how many characters have been entered. If the value is
  /// set to a positive integer it will also display the maximum allowed
  /// number of characters to be entered.  If the value is set to
  /// [TextFieldBlocBuilder.noMaxLength] then only the current length is displayed.
  ///
  /// After [maxLength] characters have been input, additional input
  /// is ignored, unless [maxLengthEnforced] is set to false. The text field
  /// enforces the length with a [LengthLimitingTextInputFormatter], which is
  /// evaluated after the supplied [inputFormatters], if any. The [maxLength]
  /// value must be either null or greater than zero.
  ///
  /// If [maxLengthEnforced] is set to false, then more than [maxLength]
  /// characters may be entered, and the error counter and divider will
  /// switch to the [decoration.errorStyle] when the limit is exceeded.
  ///
  /// The text cursor is not shown if [showCursor] is false or if [showCursor]
  /// is null (the default) and [readOnly] is true.
  ///
  /// The [textAlign], [autofocus], [obscureText], [readOnly], [autocorrect],
  /// [maxLengthEnforced], [scrollPadding], [maxLines], and [maxLength]
  /// arguments must not be null.
  ///
  /// See also:
  ///
  ///  * [maxLength], which discusses the precise meaning of "number of
  ///    characters" and how it may differ from the intuitive meaning.
  const TextFieldBlocBuilder({
    @required this.textFieldBloc,
    this.errorBuilder,
    this.formBloc,
    this.suffixButton,
    this.padding = const EdgeInsets.all(8),
    this.removeSuggestionOnLongPress = false,
    Key key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    TextInputType keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.obscureText,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.autocorrect = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforced = true,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.onTap,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.suggestionsBoxDecoration,
    this.suggestionTextStyle,
    this.debounceSuggestionDuration = const Duration(milliseconds: 300),
    this.getImmediateSuggestions = false,
    this.suggestionsAnimationDuration = const Duration(milliseconds: 700),
    this.nextFocusNode,
  })  : assert(textFieldBloc != null),
        assert(errorBuilder != null),
        assert(padding != null),
        assert(suggestionsAnimationDuration != null),
        assert(removeSuggestionOnLongPress != null),
        assert(debounceSuggestionDuration != null),
        assert(getImmediateSuggestions != null),
        assert(textAlign != null),
        assert(readOnly != null),
        assert(autofocus != null),
        assert(autocorrect != null),
        assert(maxLengthEnforced != null),
        assert(scrollPadding != null),
        assert(dragStartBehavior != null),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          'minLines can\'t be greater than maxLines',
        ),
        assert(expands != null),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(maxLength == null ||
            maxLength == TextFieldBlocBuilder.noMaxLength ||
            maxLength > 0),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        super(key: key);

  final TextFieldBloc<Error> textFieldBloc;

  /// This widget will be enable only when the [FormBloc] state is
  /// [FormBlocLoaded] or [FormBlocFailure]
  final FormBloc formBloc;

  final TextFieldBlocErrorBuilder<Error> errorBuilder;

  final SuffixButton suffixButton;

  final EdgeInsetsGeometry padding;

  final bool removeSuggestionOnLongPress;

  final SuggestionsBoxDecoration suggestionsBoxDecoration;

  /// When the field is submitted, this will call
  /// [nextFocusNode.requestFocus()]
  final FocusNode nextFocusNode;

  /// Defaults to 700 milliseconds.
  final Duration suggestionsAnimationDuration;

  /// If set to true, suggestions will be fetched immediately when the field is
  /// added to the view.
  ///
  /// But the suggestions box will only be shown when the field receives focus.
  /// To make the field receive focus immediately, you can set the `autofocus`
  /// property in the [textFieldConfiguration] to true
  ///
  /// Defaults to false
  final bool getImmediateSuggestions;

  final TextStyle suggestionTextStyle;

  /// The duration to wait after the user stops typing before calling
  /// [suggestionsCallback]
  ///
  /// This is useful, because, if not set, a request for suggestions will be
  /// sent for every character that the user types.
  ///
  /// This duration is set by default to 300 milliseconds
  final Duration debounceSuggestionDuration;

  /// --------------------------------------------------------------------------
  ///                          [TextField] properties
  /// --------------------------------------------------------------------------

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController controller;

  /// Defines the keyboard focus for this widget.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  ///
  /// ```dart
  /// FocusScope.of(context).requestFocus(myFocusNode);
  /// ```
  ///
  /// This happens automatically when the widget is tapped.
  ///
  /// To be notified when the widget gains or loses the focus, add a listener
  /// to the [focusNode]:
  ///
  /// ```dart
  /// focusNode.addListener(() { print(myFocusNode.hasFocus); });
  /// ```
  ///
  /// If null, this widget will create its own [FocusNode].
  ///
  /// ## Keyboard
  ///
  /// Requesting the focus will typically cause the keyboard to be shown
  /// if it's not showing already.
  ///
  /// On Android, the user can hide the keyboard - without changing the focus -
  /// with the system back button. They can restore the keyboard's visibility
  /// by tapping on a text field.  The user might hide the keyboard and
  /// switch to a physical keyboard, or they might just need to get it
  /// out of the way for a moment, to expose something it's
  /// obscuring. In this case requesting the focus again will not
  /// cause the focus to change, and will not make the keyboard visible.
  ///
  /// This widget builds an [EditableText] and will ensure that the keyboard is
  /// showing when it is tapped by calling [EditableTextState.requestKeyboard()].
  final FocusNode focusNode;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the text field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration decoration;

  /// {@macro flutter.widgets.editableText.obscureText}
  final bool obscureText;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction textInputAction;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The style to use for the text being edited.
  ///
  /// This text style is also used as the base style for the [decoration].
  ///
  /// If null, defaults to the `subhead` text style from the current [Theme].
  final TextStyle style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle strutStyle;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// {@macro flutter.material.inputDecorator.textAlignVertical}
  final TextAlignVertical textAlignVertical;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection textDirection;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.autocorrect}
  final bool autocorrect;

  /// {@macro flutter.widgets.editableText.maxLines}
  final int maxLines;

  /// {@macro flutter.widgets.editableText.minLines}
  final int minLines;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool showCursor;

  /// If [maxLength] is set to this value, only the "current input length"
  /// part of the character counter is shown.
  static const int noMaxLength = -1;

  /// The maximum number of characters (Unicode scalar values) to allow in the
  /// text field.
  ///
  /// If set, a character counter will be displayed below the
  /// field showing how many characters have been entered. If set to a number
  /// greater than 0, it will also display the maximum number allowed. If set
  /// to [TextFieldBlocBuilder.noMaxLength] then only the current character count is displayed.
  ///
  /// After [maxLength] characters have been input, additional input
  /// is ignored, unless [maxLengthEnforced] is set to false. The text field
  /// enforces the length with a [LengthLimitingTextInputFormatter], which is
  /// evaluated after the supplied [inputFormatters], if any.
  ///
  /// This value must be either null, [TextFieldBlocBuilder.noMaxLength], or greater than 0.
  /// If null (the default) then there is no limit to the number of characters
  /// that can be entered. If set to [TextFieldBlocBuilder.noMaxLength], then no limit will
  /// be enforced, but the number of characters entered will still be displayed.
  ///
  /// Whitespace characters (e.g. newline, space, tab) are included in the
  /// character count.
  ///
  /// If [maxLengthEnforced] is set to false, then more than [maxLength]
  /// characters may be entered, but the error counter and divider will
  /// switch to the [decoration.errorStyle] when the limit is exceeded.
  ///
  /// ## Limitations
  ///
  /// The text field does not currently count Unicode grapheme clusters (i.e.
  /// characters visible to the user), it counts Unicode scalar values, which
  /// leaves out a number of useful possible characters (like many emoji and
  /// composed characters), so this will be inaccurate in the presence of those
  /// characters. If you expect to encounter these kinds of characters, be
  /// generous in the maxLength used.
  ///
  /// For instance, the character "ö" can be represented as '\u{006F}\u{0308}',
  /// which is the letter "o" followed by a composed diaeresis "¨", or it can
  /// be represented as '\u{00F6}', which is the Unicode scalar value "LATIN
  /// SMALL LETTER O WITH DIAERESIS". In the first case, the text field will
  /// count two characters, and the second case will be counted as one
  /// character, even though the user can see no difference in the input.
  ///
  /// Similarly, some emoji are represented by multiple scalar values. The
  /// Unicode "THUMBS UP SIGN + MEDIUM SKIN TONE MODIFIER", "👍🏽", should be
  /// counted as a single character, but because it is a combination of two
  /// Unicode scalar values, '\u{1F44D}\u{1F3FD}', it is counted as two
  /// characters.
  ///
  /// See also:
  ///
  ///  * [LengthLimitingTextInputFormatter] for more information on how it
  ///    counts characters, and how it may differ from the intuitive meaning.
  final int maxLength;

  /// If true, prevents the field from allowing more than [maxLength]
  /// characters.
  ///
  /// If [maxLength] is set, [maxLengthEnforced] indicates whether or not to
  /// enforce the limit, or merely provide a character counter and warning when
  /// [maxLength] is exceeded.
  final bool maxLengthEnforced;

  /// {@macro flutter.widgets.editableText.onChanged}
  ///
  /// See also:
  ///
  ///  * [inputFormatters], which are called before [onChanged]
  ///    runs and can validate and change ("format") the input value.
  ///  * [onEditingComplete], [onSubmitted], [onSelectionChanged]:
  ///    which are more specialized input change notifications.
  final ValueChanged<String> onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  final ValueChanged<String> onSubmitted;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter> inputFormatters;

  /// If false the text field is "disabled": it ignores taps and its
  /// [decoration] is rendered in grey.
  ///
  /// If non-null this property overrides the [decoration]'s
  /// [Decoration.enabled] property.
  final bool enabled;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius cursorRadius;

  /// The color to use when painting the cursor.
  ///
  /// Defaults to the theme's `cursorColor` when null.
  final Color cursorColor;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If unset, defaults to the brightness of [ThemeData.primaryColorBrightness].
  final Brightness keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// Called when the user taps on this text field.
  ///
  /// The text field builds a [GestureDetector] to handle input events like tap,
  /// to trigger focus requests, to move the caret, adjust the selection, etc.
  /// Handling some of those events by wrapping the text field with a competing
  /// GestureDetector is problematic.
  ///
  /// To unconditionally handle taps, without interfering with the text field's
  /// internal gesture detector, provide this callback.
  ///
  /// If the text field is created with [enabled] false, taps will not be
  /// recognized.
  ///
  /// To be notified when the text field gains or loses the focus, provide a
  /// [focusNode] and add a listener to that.
  ///
  /// To listen to arbitrary pointer events without competing with the
  /// text field's internal gesture detector, use a [Listener].
  final GestureTapCallback onTap;

  /// Callback that generates a custom [InputDecorator.counter] widget.
  ///
  /// See [InputCounterWidgetBuilder] for an explanation of the passed in
  /// arguments.  The returned widget will be placed below the line in place of
  /// the default widget built when [counterText] is specified.
  ///
  /// The returned widget will be wrapped in a [Semantics] widget for
  /// accessibility, but it also needs to be accessible itself.  For example,
  /// if returning a Text widget, set the [semanticsLabel] property.
  ///
  /// {@tool sample}
  /// ```dart
  /// Widget counter(
  ///   BuildContext context,
  ///   {
  ///     int currentLength,
  ///     int maxLength,
  ///     bool isFocused,
  ///   }
  /// ) {
  ///   return Text(
  ///     '$currentLength of $maxLength characters',
  ///     semanticsLabel: 'character count',
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  final InputCounterWidgetBuilder buildCounter;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics scrollPhysics;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController scrollController;

  @override
  _TextFieldBlocBuilderState<Error> createState() =>
      _TextFieldBlocBuilderState();
}

class _TextFieldBlocBuilderState<Error>
    extends State<TextFieldBlocBuilder<Error>> {
  TextEditingController _controller;
  bool _obscureText;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.textFieldBloc.currentState.value);
    _obscureText = widget.suffixButton != null &&
        widget.suffixButton == SuffixButton.obscureText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    if (widget.nextFocusNode != null) {
      widget.nextFocusNode.requestFocus();
    }
    if (widget.onSubmitted != null) {
      widget.onSubmitted(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formBloc != null) {
      return BlocBuilder<FormBloc, FormBlocState>(
        bloc: widget.formBloc,
        builder: (context, formState) {
          return _buildChild((widget.enabled ?? true) && formState.canSubmit);
        },
      );
    } else {
      return _buildChild(true);
    }
  }

  InputDecoration buildDecoration(TextFieldBlocState<Error> state) {
    InputDecoration decoration = widget.decoration;
    if (widget.suffixButton != null) {
      switch (widget.suffixButton) {
        case SuffixButton.obscureText:
          if (widget.obscureText == null) {
            decoration = decoration.copyWith(
              suffixIcon: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  child: _obscureText
                      ? Icon(Icons.visibility)
                      : Icon(Icons.visibility_off),
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  }),
            );
          }
          break;
        case SuffixButton.clearText:
          decoration = decoration.copyWith(
            suffixIcon: InkWell(
              borderRadius: BorderRadius.circular(25),
              child: Icon(Icons.clear),
              onTap: () {
                widget.textFieldBloc.updateValue('');
              },
            ),
          );
          break;
      }
    }
    if (decoration.errorText == null &&
        widget.errorBuilder != null &&
        !state.isInitial) {
      decoration = decoration.copyWith(
        errorText: widget.errorBuilder(context, state.error),
      );
    }
    return decoration;
  }

  Widget _buildChild(bool isEnable) {
    return BlocBuilder<TextFieldBloc<Error>, TextFieldBlocState<Error>>(
      bloc: widget.textFieldBloc,
      builder: (context, fieldState) {
        if (_controller.text != fieldState.value) {
          _controller.text = fieldState.value;
        }
        return Padding(
          padding: widget.padding,
          child: TypeAheadField<String>(
            textFieldConfiguration: TextFieldConfiguration<String>(
              controller: _controller,
              decoration: buildDecoration(fieldState),
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction != null
                  ? widget.textInputAction
                  : widget.nextFocusNode != null ? TextInputAction.next : null,
              textCapitalization: widget.textCapitalization,
              style: isEnable
                  ? widget.style
                  : widget.style != null
                      ? widget.style
                          .copyWith(color: Theme.of(context).disabledColor)
                      : Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(color: Theme.of(context).disabledColor),
              textAlign: widget.textAlign,
              textDirection: widget.textDirection,
              autofocus: widget.autofocus,
              obscureText: _obscureText,
              autocorrect: widget.autocorrect,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              maxLengthEnforced: widget.maxLengthEnforced,
              onChanged: (value) {
                widget.textFieldBloc.updateValue(value);
                if (widget.onChanged != null) {
                  widget.onChanged(value);
                }
              },
              onEditingComplete: widget.onEditingComplete,
              onSubmitted: _onSubmitted,
              inputFormatters: widget.inputFormatters,
              enabled: isEnable,
              cursorWidth: widget.cursorWidth,
              cursorRadius: widget.cursorRadius,
              cursorColor: widget.cursorColor,
              keyboardAppearance: widget.keyboardAppearance,
              scrollPadding: widget.scrollPadding,
              focusNode: widget.focusNode,
            ),
            hideOnLoading: true,
            hideOnEmpty: true,
            hideOnError: true,
            getImmediateSuggestions: widget.getImmediateSuggestions,
            debounceDuration: widget.debounceSuggestionDuration,
            suggestionsCallback: (pattern) async {
              if (fieldState.suggestions != null) {
                return await fieldState.suggestions(pattern);
              }

              return null;
            },
            itemBuilder: (context, suggestion) {
              return Container(
                height: _kMenuItemHeight,
                alignment: AlignmentDirectional.centerStart,
                padding: _kMenuItemPadding,
                child: Text(
                  suggestion,
                  style: widget.suggestionTextStyle ??
                      Theme.of(context).textTheme.subhead.copyWith(
                          color: ThemeData.estimateBrightnessForColor(
                                      Theme.of(context).canvasColor) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.grey[800]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
            onSuggestionSelected: (value) {
              widget.textFieldBloc.updateValue(value);
              _onSubmitted(value);
            },
            animationDuration: widget.suggestionsAnimationDuration,
            removeSuggestionOnLongPress: widget.removeSuggestionOnLongPress,
            suggestionsBoxDecoration: widget.suggestionsBoxDecoration ??
                SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).canvasColor,
                ),
            onSuggestionRemoved: (suggestion) {
              if (widget.removeSuggestionOnLongPress) {
                widget.textFieldBloc.dispatch(RemoveSuggestion(suggestion));
              }
            },
          ),
        );
      },
    );
  }
}
