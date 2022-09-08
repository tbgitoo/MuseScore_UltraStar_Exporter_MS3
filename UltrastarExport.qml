    import QtQuick 2.2
    import QtQuick.Controls 1.1
    import QtQuick.Layouts 1.1
    import QtQuick.Dialogs 1.2
    import QtQuick.Window 2.2
    import Qt.labs.settings 1.0
    
    
    // FileDialog
    import Qt.labs.folderlistmodel 2.1
    import QtQml 2.2
    import MuseScore 3.0
    import FileIO 3.0
    
 

    // This MuseScore Plugin is licensed under the GPL Version 2
    //Copyright Joseph Eoff, April 2015
    MuseScore {
        menuPath: "Plugins." + "Ultrastar Export"
        version: "2.1"
        description: "Export to Ultrastar format"
        requiresScore: true
        pluginType: "dialog"
        
        id: pluginDialog
        width:  500
        height: 600

        onRun: {
            // check MuseScore version
            if ((mscoreMajorVersion == 3) && (mscoreMinorVersion == 0) && (mscoreUpdateVersion < 5)) {
                errorDialog.openErrorDialog(
                            qsTr("Minimum MuseScore Version %1 required for export").arg("3.0.5"))
            }
            fillDefaultValues()
        }

        Component.onDestruction: {
            settings.exportDirectory = exportDirectory.text
        }

        function fillDefaultValues() {
            instrumentPlayer2.enabled = false
            voicePlayer2.enabled = false
            loadInstrumentList(staffList)
            instrumentPlayer1.model = staffList
            instrumentPlayer2.model = staffList
            loadVoiceList(instrumentPlayer1.currentText, player1Voices, voicePlayer1);
            loadVoiceList(instrumentPlayer2.currentText, player2Voices, voicePlayer2);
            directorySelectDialog.folder = ((Qt.platform.os=="windows")? "file:///" : "file://") + exportDirectory.text;
        }

        function loadInstrumentList(instrumentList) {
            for (var i = 0; i < curScore.parts.length; i++) {
                var partName = curScore.parts[i].name;
                //in v3.0.5/3.1 plugin framework isn't able to return the actual instrument/partname
                if (partName === "Part") { // so let's enumerate it in that case
                    partName += " " + (i + 1);
                }
                instrumentList.append({ partname: partName });
            }
        }

        function loadVoiceList(instrumentName, voiceList, voiceCombo) {
            if(curScore && curScore.parts)
            {
                for (var i = 0; i < curScore.parts.length; i++) {
                    var partName = curScore.parts[i].name;
                    //in v3.0.5/3.1 plugin framework isn't able to return the actual instrument/partname
                    if (partName === "Part") { // so let's enumerate it in that case
                        partName += " " + (i + 1);
                    }
                    if (partName === instrumentName) {
                        voiceList.clear();
                        for (var j = 0; j < (curScore.parts[i].endTrack - curScore.parts[i].startTrack); j++) {
                            voiceList.append({ j: (j + 1) });
                        }
                    }
                }
            }
            voiceCombo.model = voiceList; //applying the new list sets currentIndex to 0, but doesn't update the shown comboboxText
            voiceCombo.currentIndex = 1;  //force an indexChange to force the combo to update its label
            voiceCombo.currentIndex = 0;  //force indexChange back to default, now the label will be updated
        }

        Settings {
            id: settings
            property alias exportDirectory: exportDirectory.text
            property alias highAccuracyMode: highAccuracyMode.checked
            property alias variableSpeedMode: variableSpeedMode.checked
            property alias exportVideo: exportVideo.checked
        }

        ListModel {
            id: staffList
        }

        ListModel {
            id: player1Voices
        }

        ListModel {
            id: player2Voices
        }

        MessageDialog {
            id: errorDialog
            visible: false
            title: qsTr("Error")
            text: "Error"
            onAccepted: {
                exportDialog.visible = false
                Qt.quit()
            }
            function openErrorDialog(message) {
                text = message
                open()
            }
        }

        MessageDialog {
            id: warningDialog
            visible: false
            title: qsTr("Warning")
            text: "Warning"
            onAccepted: {
                Qt.quit()
            }
            function openWarningDialog(message) {
                text = message
                open()
            }
        }

        FileIO {
            id: songTextWriter
            onError: console.log(msg + "  Filename = " + songTextWriter.source)
        }

        FileDialog {
            id: directorySelectDialog
            title: qsTr("Please choose a directory")
            selectFolder: true
            visible: false
            onAccepted: {
                exportDirectory.text = this.folder.toString().replace("file://", "").replace(/^\/(.:\/)(.*)$/, "$1$2");
            }
            Component.onCompleted: visible = false
        }
        
        GridLayout {
                        id: grid
                        columns: 2
                        anchors.fill: parent
                        anchors.margins: 10
                        Label {
                            text: qsTr("Player 1")
                            Layout.columnSpan: 2
                        }
                        Label {
                            text: qsTranslate("Ms::MuseScore", "Instrument")
                        }
                        ComboBox {
                            id: instrumentPlayer1
                            onCurrentIndexChanged: {
                                loadVoiceList(currentText, player1Voices, voicePlayer1);
                            }
                        }
                        Label {
                            text: qsTr("Voice")
                        }
                        ComboBox {
                            id: voicePlayer1
                        }
                        Label {
                            text: qsTr("Duet")
                        }
                        CheckBox {
                            id: duet
                            onClicked: {
                                instrumentPlayer2.enabled = checked
                                voicePlayer2.enabled = checked
                            }
                        }
                        Label {
                            text: qsTr("Player 2")
                            Layout.columnSpan: 2
                        }
                        Label {
                            text: qsTranslate("Ms::MuseScore", "Instrument")
                        }
                        ComboBox {
                            id: instrumentPlayer2
                            onCurrentIndexChanged: {
                                loadVoiceList(currentText, player2Voices, voicePlayer2);
                            }
                        }
                        Label {
                            text: qsTr("Voice")
                        }
                        ComboBox {
                            id: voicePlayer2
                        }
                        Label {
                            text: qsTr("Export folder")
                        }
                        Button {
                            id: selectDirectory
                            text: qsTranslate("ScoreComparisonTool", "Browse")
                            onClicked: {
                                directorySelectDialog.open();
                            }
                        }
                        Label {
                            id: exportDirectory
                            text: ""
                            Layout.columnSpan: 2
                        }
                        Label {
                            text: qsTr("Handling of special durations")
                            Layout.columnSpan: 2
                        }
                        Label {
                            text: qsTr("Variable Speed Mode \n(BPM change for tuplets)")
                        }
                        CheckBox {
                            id: variableSpeedMode
                            checked: true
                            onClicked: {
                                if(highAccuracyMode.checked && variableSpeedMode.checked){
                                    highAccuracyMode.checked=false
                                }
                            }
                        }
                        Label {
                            text: qsTr("High Accuracy Mode \n(BPM change and higher sampling)")
                        }
                        CheckBox {
                            id: highAccuracyMode
                            checked: false
                            onClicked: {
                                if(highAccuracyMode.checked && variableSpeedMode.checked){
                                    variableSpeedMode.checked=false
                                }
                            }
                        }
                        Label {
                            text: qsTr("Export video file")
                        }
                        CheckBox {
                            id: exportVideo
                            checked: true
                        }
                        Button {
                            id: exportButton
                            text: qsTranslate("PrefsDialogBase", "Export")
                            onClicked: {
                                exportUltrastar()
                                //Qt.quit()
                            } // onClicked
                        }
                        Button {
                            id: cancelButton
                            text: qsTr("Cancel")
                            onClicked: {
                                Qt.quit()
                            } // onClicked
                        }
                        Label {
                            id: exportStatus
                            text: ""
                        }
        }

        

        function exportUltrastar() {
            exportStatus.text = qsTr("Exporting .txt File.")
            if (!exportTxtFile()) {
                return false
            }
            exportStatus.text = qsTr("Exporting .mp3 File.")
            exportAudioFile()
            exportStatus.text = ""
            if(exportVideo.checked)
            {
            exportStatus.text = qsTr("Exporting .mpg File.")
            exportVideoFile()
            exportStatus.text = ""
            }
            
        }

        function exportTxtFile() {
            var crlf = "\r\n"
            var title = curScore.metaTag("workTitle");
            if (!(title)) {
                warningDialog.openWarningDialog(qsTr("Score must have a title."))
                return false
            }
            var filename = exportDirectory.text + "//" + filenameFromScore(
                        ) + ".txt"
            console.log(filename)

            var txtContent = ""
            if (duet.checked) {
                title += " Duet"
            }
            title += " " + instrumentPlayer1.currentText
            if (duet.checked) {
                title += " + " + instrumentPlayer2.currentText
            }
            txtContent += "#TITLE:" + title + crlf

            var composer = curScore.metaTag("composer");
            if (!(composer)) {
                warningDialog.openWarningDialog(qsTr("Score must have a composer."))
                return false
            }
            txtContent += "#ARTIST:" + composer + crlf

            txtContent += "#MP3:" + filenameFromScore() + ".mp3" + crlf
            if(exportVideo.checked)
            {
                txtContent += "#VIDEO:" + filenameFromScore() + ".mpg" + crlf
                txtContent += "#VIDEOGAP:1" + crlf
            } else {
                txtContent += "#VIDEO:" + crlf
                txtContent += "#VIDEOGAP:" + crlf
            }
            txtContent += "#START:0" + crlf

            txtContent += "#BPM:" + getTempo_BPM() + crlf;

            txtContent += "#GAP:0" + crlf

            if (duet.checked) {
                txtContent += "P1" + crlf
            }

            var cursor = getCursor(instrumentPlayer1.currentText,
                                voicePlayer1.currentIndex)

            cursor.rewind(0)
            txtContent += getSongText(cursor);

            if (duet.checked) {
                txtContent += "P2" + crlf
                cursor = getCursor(instrumentPlayer2.currentText,
                                voicePlayer2.currentIndex)
                txtContent += getSongText(cursor);
            }
            txtContent += "E" + crlf
            console.log(txtContent)
            songTextWriter.source = filename
            songTextWriter.write(txtContent)
            return true
        }

        function getSongText(cursor) {
            var crlf = "\r\n";
            var syllable = "";
            var songContent = "";
            var pitch_midi;
            var timestamp_midi_ticks=0;
            var duration_midi_ticks=0;
            var gotfirstsyllable = false;
            var needABreak = false;
            var tookAbreak = false;
            var makeGolden = false;
            var makeFreestyle = false;
            var prematureSyllableBreakNeeded=false;
            var lineHeader = ":";
            var changedTempo = undefined;
            var additional_ticks_tuplets = 0; // This is to compensate for tuplets, that go faster than the indicated base rate. Used only in variableSpeedMode
            var currentBPM = getTempo_BPM();
            var currentTupletCorrectedBPM = getTempo_BPM(); // in variableSpeedMode
            var previousTupletCorrectedBPM = getTempo_BPM(); // in variableSpeedMode only
            var previousWasRest = false;
            // There are two issues with the tuplets (most common: triolets, but everything else is theoretically possible).
            // First, in MuseScore, the nominal note duration in ticks
            // is counted differently from actual note duration when going to the beginning of the next note.
            // This poses a problem of mismath upon transcription regarding the duration of the notes, their nominal duration is longer than their actual, this
            // has to be taken into account upon note duration evaluation.
            // A second issue is specific to Ultrastar. Ultrastar does foresee tuplets and due to the relatively slow sampling, tuplets are usually not well
            // represented and analyzed. A complete solution is proposed in high "High Accuracy Mode"
            // which includes both much higher Ultrastar sampling and compensation for tuplet duration with local adjustment of song speed (BPM)
            // A solution including only the variable speed for tuplets is "variableSpeedMode" where the
            // BPM is adjusted for tuplets so that their duration is exact. This leaves the BPM at directly human understandable values related to
            // actual BPM, but may not capture other fine details. Since the variable speed is included in the high accuracy mode, it doesn't make
            // sense to combine the two and one can not check both boxes.
            
            timestamp_midi_ticks = calculateMidiTicksfromTicks(cursor.tick);
        
            while (cursor.segment) {
                if (hasLyricsatCurrentLocation(cursor)){
                    if (cursor.element.lyrics[0].text!="_"&&cursor.element.lyrics[0].text!=""){
                        if (tiedBack(cursor)){
                            console.log("breaking syllables on " + cursor.element.lyrics[0].text);
                            prematureSyllableBreakNeeded=true;
                        }
                    }
                }
                
                if ((prematureSyllableBreakNeeded || needABreak || !tiedBack(cursor)) && duration_midi_ticks>0) {
                    if (syllable==""){
                        syllable="_"
                    }
                    songContent += lineHeader + " " + timestamp_midi_ticks + " " + duration_midi_ticks + " " + pitch_midi + " " + syllable + crlf
                    timestamp_midi_ticks = calculateMidiTicksfromTicks(cursor.tick+additional_ticks_tuplets);
                    syllable=""
                    duration_midi_ticks=0
                }

                if (needABreak && gotfirstsyllable) {
                    timestamp_midi_ticks = calculateMidiTicksfromTicks(cursor.tick+additional_ticks_tuplets);
                    songContent += "-" + timestamp_midi_ticks + crlf
                    needABreak=false;
                    tookAbreak=true;
                }
                
                if(previousWasRest)
                {
                    timestamp_midi_ticks = calculateMidiTicksfromTicks(cursor.tick+additional_ticks_tuplets);
                }
        
                needABreak = checkForMarkerInStaffText(cursor.segment, "/", true)
                makeGolden = checkForMarkerInStaffText(cursor.segment, "*", true)
                makeFreestyle = checkForMarkerInStaffText(cursor.segment, "F", true)
                changedTempo = getNewBPMFromSegment(cursor.segment);
                console.log(changedTempo);
                prematureSyllableBreakNeeded=makeGolden||makeFreestyle||changedTempo

                if (hasLyricsatCurrentLocation(cursor)) {
                    syllable += getLyricsAtCurrentLocation(cursor);
                }
                if (cursor.element && cursor.element.type === Element.CHORD) {
                    previousWasRest=false;
                    if (tookAbreak){
                        tookAbreak=false;
                        timestamp_midi_ticks = calculateMidiTicksfromTicks(cursor.tick+additional_ticks_tuplets);
                    }
                    pitch_midi = cursor.element.notes[0].pitch
                    duration_midi_ticks += calculateMidiTicksfromTicks(cursor.element.duration.ticks);
                    
                    if (!gotfirstsyllable) {
                        gotfirstsyllable = true
                        timestamp_midi_ticks = calculateMidiTicksfromTicks(cursor.tick+additional_ticks_tuplets);
                    }
                    
                    var currentTupletRatio=tupletRatio(cursor);
                    if (variableSpeedMode.checked)
                    {
                        // The logics behind this is that since we use the BPM to advance faster during tuplets, we also need to advance
                        // the ticks faster.
                        additional_ticks_tuplets+=Math.round(cursor.element.duration.ticks*(1-1.0/currentTupletRatio));
                    } else {
                        // No adjustment for midi ticks if we don't want to change BPM for the tuplet
                        currentTupletRatio=1; // No correction for tuplets unless we are in variableSpeedMode
                    }

                    lineHeader = ":"
                    if (makeGolden) {
                        lineHeader = "*"
                    }
                    if (makeFreestyle) {
                        lineHeader = "F"
                    }
                    
                    if (changedTempo) {
                        currentBPM=changedTempo;
                    }
                    if (variableSpeedMode.checked) // changes in BPM to implement the tuplets in Ultrastar, only done in variableSpeedMode
                    {
                        currentTupletCorrectedBPM=currentBPM*currentTupletRatio;
                        if(currentTupletCorrectedBPM != previousTupletCorrectedBPM)
                        {
                            previousTupletCorrectedBPM=currentTupletCorrectedBPM;
                            songContent += "B " + timestamp_midi_ticks + " " + currentTupletCorrectedBPM + crlf;
                    
                        }
                    }
                    
                    
                }
                if (cursor.element && cursor.element.type === Element.REST) {
                        previousWasRest=true;
                }
                
                cursor.next()
            }
            if (syllable!=""){
                songContent += lineHeader + " " + timestamp_midi_ticks + " " + duration_midi_ticks + " " + pitch_midi + " " + syllable + crlf
            }
            return songContent
        }
        
        function hasLyricsatCurrentLocation(cursor){
            var hasLyrics=false
            if (cursor.element && cursor.element.type === Element.CHORD) {
                if (cursor.element.lyrics.length > 0) {
                    hasLyrics=true;
                }
            }
        return hasLyrics;
        }
        
        function getLyricsAtCurrentLocation(cursor){
            var lyrics="-";
                if (hasLyricsatCurrentLocation(cursor)){
                    lyrics = cursor.element.lyrics[0].text

                    if (cursor.element.lyrics[0].syllabic === Lyrics.SINGLE || cursor.element.lyrics[0].syllabic === Lyrics.END) {
                        lyrics += " "
                    }
                    else {
                        lyrics += "-"
                    }
                }
            return lyrics;
        }
        
        function tupletRatio(cursor){
                
                var theoretical_duration_ticks = cursor.element.duration.ticks;
                var real_duration_ticks = cursor.element.globalDuration.ticks;
                return theoretical_duration_ticks/real_duration_ticks;
        }
        
        
        function tiedBack(cursor){
        var tied=false
        if (cursor.segment && cursor.element && (cursor.element.type === Element.CHORD) && (cursor.element.notes[0].tieBack != null)){
        tied=true;
        }
        return tied
        }

        function checkForMarkerInStaffText(segment, marker, hide) {
            for (var i = 0; i < segment.annotations.length; i++) {
                if (segment.annotations[i].type === Element.STAFF_TEXT) {
                    if (segment.annotations[i].text === marker) {
                        if (hide && segment.annotations[i].visible){
                            curScore.startCmd()
                            segment.annotations[i].visible=false
                            curScore.endCmd(false)
                        }
                        return true
                    }
                }
            }
            return false
        }

        function getNewBPMFromSegment(segment) {
            for (var i = 0; i < segment.annotations.length; i++) {
                if (segment.annotations[i].type === Element.TEMPO_TEXT) {
                    return calculateBPMfromTempo(segment.annotations[i].tempo);
                }
            }
            return undefined; //invalid - no tempo text found
        }
        
        
        function calculateMidiTicksfromTicks(ticks) {
            if (highAccuracyMode.checked)
            {
                // /5 because values at https://musescore.org/plugin-development/tick-length-values are all multiples of 5
                // and we want to have maximal precision whilst keeping numeric values as small as possible
                return (ticks / 5);
            }
            else
            {//normal accuracy mode
                //division is a global variable holding the tickLength of a crochet(1/4th note)
                return Math.round(ticks / division * 4); // *4 scales from crotchet-reference to whole measure
            }
        }

        function getCursor(instrument, voice) {
            for (var i = 0; i < curScore.parts.length; i++) {
                var partName = curScore.parts[i].name;
                //in v3.0.5/3.1 plugin framework isn't able to return the actual instrument/partname
                if (partName === "Part") { // so let's enumerate it in that case
                    partName += " " + (i + 1);
                }
                if (partName === instrument) {
                    var track = curScore.parts[i].startTrack + parseInt(voice, 10)
                    var cursor = curScore.newCursor(true)
                    cursor.rewind(1)
                    cursor.track = track
                    cursor.rewind(0)
                    return cursor
                }
            }
        }

        function calculateBPMfromTempo(tempo) {
            //tempo is a % compared to 60bpm (tempo == 1 -> bpm == 60)
            if (highAccuracyMode.checked)
            {
                //division is a global variable holding the tickLength of a crochet(1/4th note)
                //scaling tempo with tickLength allows very precise approximation of real note lengths in export
                // *15 (*60 for real BPM, then /4 to scale to crotchet because 4* crotchet == 60 and division is in crotchet)
                // /5 because values at https://musescore.org/plugin-development/tick-length-values are all multiples of 5
                // and we want to have maximal precision whilst keeping numeric values as small as possible
                // so in total we do (*15/5) == * 3
                return (tempo * division * 3);
            }
            else
            {//normal accuracy mode
                return (tempo * 60);
            }
        }

        function getTempo_BPM() {
            var bpm = 2; //default BPM = 120bpm = 200% = 2 according to https://musescore.org/en/node/16635
            //song BPM is expected at the first chord/rest of the score, so let's find it
            var segment = curScore.firstSegment(Segment.ChordRest);
            //filter on firstSegment doesn't seem to work, so stepping here manually
            while ((segment != null) && (segment.segmentType !== Segment.ChordRest)) {
                if (segment != null) { //found first chord/rest of the score
                //let's see if there's a TEMPO_TEXT assigned to it
                    for (var i = segment.annotations.length; i-- > 0; ) {
                        if (segment.annotations[i].type === Element.TEMPO_TEXT) {
                            bpm = segment.annotations[i].tempo;
                            break;
                        }
                    }
                }
                segment = segment.nextInMeasure;
            }
            
            console.log('Tempo: ' + bpm + ' | Real BPM: ' + (bpm * 60));
            bpm = calculateBPMfromTempo(bpm);
            console.log('\tTickBPM: ' + bpm);
            return bpm;
        }

        function exportAudioFile() {
            var filename = exportDirectory.text + "//" + filenameFromScore()
            writeScore(curScore, filename, "mp3")
        }

        function filenameFromScore() {
            var name = curScore.metaTag("workTitle");
            if (duet.checked) {
                name += " duet"
            }
            name += " " + instrumentPlayer1.currentText
            if (duet.checked) {
                name += " " + instrumentPlayer2.currentText
            }
            name = name.replace(/ /g, "_")
            return name
        }
        
        
        function exportVideoFile()
        {
            pluginDialog.parent.Window.window.hide()
            
            
            videoDialog.show();
            //var theScreen = Qt.application.screens[0];
            
            
        }
        
        function desktopVideoStreamOption()
        {
            return (' -f avfoundation  -i "1" ')
        }
        
        function getVideoPixelRatio()
        {
            var ffprobe_command = "ffprobe "+desktopVideoStreamOption()+" -show_entries stream=width,height"
            ffmpeg_process.start(ffprobe_command)
            ffmpeg_process.waitForFinished(3000)
            var video_screen_size=String(ffmpeg_process.readAllStandardOutput())
            var width_position=video_screen_size.indexOf("width")
            var height_position=video_screen_size.indexOf("height")
            var width_string = video_screen_size.substr(width_position+6,height_position-width_position-7)
            return(width_string.valueOf()/Qt.application.screens[0].width)
            
            
            
        }
        
        
        
        
        
        FileIO {
            id: videoTemp
            onError: console.log(msg + "  Filename = " + videoTemp.source)
        }
        
        QProcess{
            id: ffmpeg_process
        }
        
        Timer {
        id: timer
        }
        
        function delay(delayTime,cb) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.start();
        }
        
        Timer {
        id: timer2
        }
        
        function delay2(delayTime,cb) {
            timer2.interval = delayTime;
            timer2.repeat = false;
            timer2.triggered.connect(cb);
            timer2.start();
        }
        
        
        
        Window {
        id: videoProcessingDialog
        visible: false
        title: qsTr("UltraStarExport: Video Processing")
        width: 600
        height: 300
        color: "#d7d6d5"
        Rectangle {
            width: parent.width
            height: parent.height
            GridLayout {
                id: grid_processing_messages
                columns: 2
                anchors.fill: parent
                anchors.margins: 10
                Label {
                        id: processing_messages
                        text: qsTr("Completing capture ...")
                        Layout.columnSpan: 2
                        }
                Button {
                            id: doneButtonProcessing
                            text: qsTr("OK")
                            visible: false
                            onClicked: {
                                       videoProcessingDialog.visible=false
                            }
                        
                }
                
            }
        }
        }
        
        
        
        
        
        
        
        Window {
        id: videoDialog
        visible: false
        title: qsTr("Video Export")
        width: 600
        height: 300
        opacity: 0.95
        
        Rectangle {
            width: parent.width
            height: parent.height
            GridLayout {
                id: grid_transparency
                columns: 2
                anchors.fill: parent
                anchors.margins: 10
                Label {
                        text: qsTr("Select video capture area")
                        Layout.columnSpan: 2
                        }
                Label {
                        text: qsTr("Adjust this window such that it covers the area of interest")
                        Layout.columnSpan: 2
                        }
                Label {
                        text: qsTr("Use the toggle transparency button to view through the window")
                        Layout.columnSpan: 2
                        }
                Button {
                            id: tranparencySecondary
                            text: qsTr("Toggle Transparency")
                            onClicked: {
                                if(videoDialog.opacity==0.95) {videoDialog.opacity=0.2 } else {videoDialog.opacity=0.95}
                            } // onClicked
                }
                
                Button {
                            id: doneButtonSecondary
                            text: qsTr("Done")
                            onClicked: {
                            
                                       
                            
                                var pixelRatio=getVideoPixelRatio() // Qt has "device-independent pixels"
                                var filename = videoTemp.tempPath() + "/" + filenameFromScore() + ".mpg"
                                var topX = videoDialog.x
                                var topY = videoDialog.y
                                var widthDialog = videoDialog.width
                                var heightDialog = videoDialog.height
                                videoDialog.opacity=0
                                var songTime = curScore.duration
                                var ffmpeg_command = 'ffmpeg -y -t '+(songTime+2)+desktopVideoStreamOption()+' -vf "crop='+(widthDialog*pixelRatio)+':'+(heightDialog*pixelRatio)+':'+(topX*pixelRatio)+':'+(topY*pixelRatio) +'"  -r 24 "'+filename+'" '
                                cmd("rewind")
                                
                                ffmpeg_process.start(ffmpeg_command)
                                
                                
                                delay2(1000,function(){cmd("play")})
                                
                                delay((songTime+1.5)*1000, function() {
                                        
                                        videoProcessingDialog.show()
                                        
                                        ffmpeg_process.waitForFinished(3000)
                                        
                                        endProcessing(songTime)
                                        
                                        //pluginDialog.parent.Window.window.show()

                                })
                                
                                
        
                                
                                //
                                
                            } // onClicked
                }
            }
        }
                        
                        
                        
        
        
        }
        
        
        function endProcessing(songTime){
            processing_messages.text="Processing for Ultrastar, please wait"
            console.log(filePath)
            
            var filename = videoTemp.tempPath() + "/" + filenameFromScore() + ".mpg"
            var ffmpeg_command = 'ffmpeg -y -loop 1 -i "'+filePath+'/resources/white.png" -i "'+filename+'" -filter_complex "[1]scale=1 500:-1[n];[0][n]overlay=shortest=1:x=(main_w-overlay_w)/2:y=200" "'+exportDirectory.text+'/'+filenameFromScore() + '.mpg"'
            
            ffmpeg_process.start(ffmpeg_command)
            console.log(ffmpeg_process.waitForFinished(1000*songTime)) // It shouldn't take longer than the song to process this
            
            doneButtonProcessing.visible=true
            
            
        }
        
        
    }

