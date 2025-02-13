import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/ui/components/loading_loop.dart';


class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SaveState();
  }
}

class _SaveState extends State<SavePage> {
  _SaveState();

  String selectedFileName = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Image.asset(
            "assets/page_background.png",
            fit: BoxFit.fitHeight,
          ),
          Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20.adaptedFontSize,
                      fontWeight: FontWeight.w600),
                  toolbarHeight: 65.adaptedHeight,
                  title: _getAppTitle()),
              backgroundColor: Colors.transparent,
              body: Padding(
                padding: EdgeInsets.only(
                    right: 16.adaptedWidth, left: 16.adaptedWidth, top: 80.adaptedHeight, bottom: 30.adaptedHeight),
                child: Center(child: BlocBuilder<RemoFileBloc, RemoFileState>(
                    builder: (context, remoFileState) {
                  if (remoFileState is SavingRecord) {
                    return LoadingLoop();
                  }

                  if (remoFileState is RemoFileReady) {
                    Future.delayed(Duration(seconds: 2), () {
                      if(context.mounted) {
                        Navigator.pop(context);
                      }
                    });
                  }

                  if (remoFileState is RecordSaved || remoFileState is RemoFileReady) {
                    return Image.asset("assets/check_mark.png");
                  }

                  return _buildSaveScreen();
                })),
              )),
        ],
      ),
    );
  }

  Widget _buildSaveScreen() {
    return Column(
      children: [
        const Text("Your file will be saved in the download folder"),
        SizedBox(height: 46.adaptedHeight),
        const Text("Insert file name:"),
        SizedBox(height: 15.adaptedHeight),
        _buildForm(),
        Spacer(),
        FilledButton(
          onPressed: () {
            context.read<RemoFileBloc>().add(SaveRecord(selectedFileName));
          },
          style: FilledButton.styleFrom(
            fixedSize: Size(
              343.adaptedWidth,
              48.adaptedHeight,
            ),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(60.adaptedRadius))),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Text('Save',
              style: TextStyle(
                  fontSize: 20.adaptedFontSize, fontWeight: FontWeight.w600)),
        ),
        SizedBox(height: 25.adaptedHeight),
        TextButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => _buildDiscardConfirmDialog()),
          child: Text(
            'Discard',
            style: TextStyle(
                fontSize: 20.adaptedFontSize,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 26.adaptedHeight),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: TextFormField(
        autocorrect: false,
        enableSuggestions: false,
        textAlign: TextAlign.center,
        onChanged: (String value) {
          selectedFileName = value;
        },
        decoration: const InputDecoration(
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedErrorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEDEDF5))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEDEDF5))),
            fillColor: Colors.white,
            filled: true,
            hintText: "RecordName",
            hintStyle: TextStyle(color: Color(0xFFC2C8D2))),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'You need to name it';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDiscardConfirmDialog() {
    return AlertDialog(
        title: null,
        contentPadding: EdgeInsets.all(0),
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.adaptedRadius))),
        content: SizedBox(
          width: 343.adaptedWidth,
          height: 352.adaptedHeight,
          child: Column(
            children: [
              SizedBox(height: 33.adaptedHeight),
              Image.asset("assets/trash_icon.png"),
              SizedBox(height: 17.adaptedHeight),
              Text("Want to delete?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22.adaptedFontSize,
                      color: Color(0xFF2B3A51),
                      fontWeight: FontWeight.w700)),
              Text(
                  "Are you sure want to delete the file?\nYou will not be able to recover it.",
                  textAlign: TextAlign.center),
              SizedBox(height: 34.adaptedHeight),
              FilledButton(
                onPressed: () {
                  context.read<RemoFileBloc>().add(DiscardRecord());
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  fixedSize: Size(
                    163.adaptedWidth,
                    48.adaptedHeight,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(60.adaptedRadius))),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text('Delete',
                    style: TextStyle(
                        fontSize: 20.adaptedFontSize,
                        fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 25.adaptedHeight),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 20.adaptedFontSize,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _getAppTitle() {
    return BlocBuilder<RemoFileBloc, RemoFileState>(
        builder: (context, remoFileState) {
      if (remoFileState is RecordSaved || remoFileState is RemoFileReady) {
        return const Text("Saved!");
      }

      if (remoFileState is SavingRecord) {
        return const Text("Saving...");
      }

      return const Text("Want to save the record?");
    });
  }
}
