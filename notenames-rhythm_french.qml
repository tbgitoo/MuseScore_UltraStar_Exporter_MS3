/*-
 * Copyright © 2020, 2021
 *    mirabilos <m@mirbsd.org>
 *
 * Provided that these terms and disclaimer and all copyright notices
 * are retained or reproduced in an accompanying document, permission
 * is granted to deal in this work without restriction, including un‐
 * limited rights to use, publicly perform, distribute, sell, modify,
 * merge, give away, or sublicence.
 *
 * This work is provided “AS IS” and WITHOUT WARRANTY of any kind, to
 * the utmost extent permitted by applicable law, neither express nor
 * implied; without malicious intent or gross negligence. In no event
 * may a licensor, author or contributor be held liable for indirect,
 * direct, other damage, loss, or other issues arising in any way out
 * of dealing in the work, even if advised of the possibility of such
 * damage or existence of a defect, except proven that it results out
 * of said person’s immediate fault when using the work as intended.
 *-
 * Number notes’ beats. Note that short measures could be aligned any
 * conceivable way (beginning, end, middle) so we assume beginning as
 * MuseScore doesn’t record short measure alignment.
 *
 * Makes use of some techniques demonstrated by the MuseScore example
 * plugins. No copyright is claimed for these or the API extracts.
 */

import MuseScore 3.0

MuseScore {
    description: "This plugin inserts beat numbers as staff text.";
    requiresScore: true;
    version: "1";
    menuPath: "Plugins.Notes.French rhythm";

    function buildMeasureMap(score) {
        var map = {};
        var no = 1;
        var cursor = score.newCursor();
        cursor.rewind(Cursor.SCORE_START);
        while (cursor.measure) {
            var m = cursor.measure;
            var tick = m.firstSegment.tick;
            var tsD = m.timesigActual.denominator;
            var tsN = m.timesigActual.numerator;
            var ticksB = division * 4.0 / tsD;
            var ticksM = ticksB * tsN;
            no += m.noOffset;
            var cur = {
                "tick": tick,
                "tsD": tsD,
                "tsN": tsN,
                "ticksB": ticksB,
                "ticksM": ticksM,
                "past" : (tick + ticksM),
                "no": no
            };
            map[cur.tick] = cur;
            console.log(tsN + "/" + tsD + " measure " + no +
                " at tick " + cur.tick + " length " + ticksM);
            if (!m.irregular)
                ++no;
            cursor.nextMeasure();
        }
        return map;
    }

    function showPos(cursor, measureMap) {
        var t = cursor.segment.tick;
        var m = measureMap[cursor.measure.firstSegment.tick];
        var b = "?";
        if (m && t >= m.tick && t < m.past) {
            b = 1 + (t - m.tick) / m.ticksB;
        }

        return "St" + (cursor.staffIdx + 1) +
            " Vc" + (cursor.voice + 1) +
            " Ms" + m.no + " Bt" + b;
    }

    function nameElementType(elementType) {
        switch (elementType) {
        case Element.ACCIDENTAL:
            return "ACCIDENTAL";
        case Element.AMBITUS:
            return "AMBITUS";
        case Element.ARPEGGIO:
            return "ARPEGGIO";
        case Element.ARTICULATION:
            return "ARTICULATION";
        case Element.BAGPIPE_EMBELLISHMENT:
            return "BAGPIPE_EMBELLISHMENT";
        case Element.BAR_LINE:
            return "BAR_LINE";
        case Element.BEAM:
            return "BEAM";
        case Element.BEND:
            return "BEND";
        case Element.BRACKET:
            return "BRACKET";
        case Element.BRACKET_ITEM:
            return "BRACKET_ITEM";
        case Element.BREATH:
            return "BREATH";
        case Element.CHORD:
            return "CHORD";
        case Element.CHORDLINE:
            return "CHORDLINE";
        case Element.CLEF:
            return "CLEF";
        case Element.COMPOUND:
            return "COMPOUND";
        case Element.DYNAMIC:
            return "DYNAMIC";
        case Element.ELEMENT:
            return "ELEMENT";
        case Element.ELEMENT_LIST:
            return "ELEMENT_LIST";
        case Element.FBOX:
            return "FBOX";
        case Element.FERMATA:
            return "FERMATA";
        case Element.FIGURED_BASS:
            return "FIGURED_BASS";
        case Element.FINGERING:
            return "FINGERING";
        case Element.FRET_DIAGRAM:
            return "FRET_DIAGRAM";
        case Element.FSYMBOL:
            return "FSYMBOL";
        case Element.GLISSANDO:
            return "GLISSANDO";
        case Element.GLISSANDO_SEGMENT:
            return "GLISSANDO_SEGMENT";
        case Element.HAIRPIN:
            return "HAIRPIN";
        case Element.HAIRPIN_SEGMENT:
            return "HAIRPIN_SEGMENT";
        case Element.HARMONY:
            return "HARMONY";
        case Element.HBOX:
            return "HBOX";
        case Element.HOOK:
            return "HOOK";
        case Element.ICON:
            return "ICON";
        case Element.IMAGE:
            return "IMAGE";
        case Element.INSTRUMENT_CHANGE:
            return "INSTRUMENT_CHANGE";
        case Element.INSTRUMENT_NAME:
            return "INSTRUMENT_NAME";
        case Element.JUMP:
            return "JUMP";
        case Element.KEYSIG:
            return "KEYSIG";
        case Element.LASSO:
            return "LASSO";
        case Element.LAYOUT_BREAK:
            return "LAYOUT_BREAK";
        case Element.LEDGER_LINE:
            return "LEDGER_LINE";
        case Element.LET_RING:
            return "LET_RING";
        case Element.LET_RING_SEGMENT:
            return "LET_RING_SEGMENT";
        case Element.LYRICS:
            return "LYRICS";
        case Element.LYRICSLINE:
            return "LYRICSLINE";
        case Element.LYRICSLINE_SEGMENT:
            return "LYRICSLINE_SEGMENT";
        case Element.MARKER:
            return "MARKER";
        case Element.MEASURE:
            return "MEASURE";
        case Element.MEASURE_LIST:
            return "MEASURE_LIST";
        case Element.MEASURE_NUMBER:
            return "MEASURE_NUMBER";
        case Element.NOTE:
            return "NOTE";
        case Element.NOTEDOT:
            return "NOTEDOT";
        case Element.NOTEHEAD:
            return "NOTEHEAD";
        case Element.NOTELINE:
            return "NOTELINE";
        case Element.OSSIA:
            return "OSSIA";
        case Element.OTTAVA:
            return "OTTAVA";
        case Element.OTTAVA_SEGMENT:
            return "OTTAVA_SEGMENT";
        case Element.PAGE:
            return "PAGE";
        case Element.PALM_MUTE:
            return "PALM_MUTE";
        case Element.PALM_MUTE_SEGMENT:
            return "PALM_MUTE_SEGMENT";
        case Element.PART:
            return "PART";
        case Element.PEDAL:
            return "PEDAL";
        case Element.PEDAL_SEGMENT:
            return "PEDAL_SEGMENT";
        case Element.REHEARSAL_MARK:
            return "REHEARSAL_MARK";
        case Element.REPEAT_MEASURE:
            return "REPEAT_MEASURE";
        case Element.REST:
            return "REST";
        case Element.SCORE:
            return "SCORE";
        case Element.SEGMENT:
            return "SEGMENT";
        case Element.SELECTION:
            return "SELECTION";
        case Element.SHADOW_NOTE:
            return "SHADOW_NOTE";
        case Element.SLUR:
            return "SLUR";
        case Element.SLUR_SEGMENT:
            return "SLUR_SEGMENT";
        case Element.SPACER:
            return "SPACER";
        case Element.STAFF:
            return "STAFF";
        case Element.STAFFTYPE_CHANGE:
            return "STAFFTYPE_CHANGE";
        case Element.STAFF_LINES:
            return "STAFF_LINES";
        case Element.STAFF_LIST:
            return "STAFF_LIST";
        case Element.STAFF_STATE:
            return "STAFF_STATE";
        case Element.STAFF_TEXT:
            return "STAFF_TEXT";
        case Element.STEM:
            return "STEM";
        case Element.STEM_SLASH:
            return "STEM_SLASH";
        case Element.STICKING:
            return "STICKING";
        case Element.SYMBOL:
            return "SYMBOL";
        case Element.SYSTEM:
            return "SYSTEM";
        case Element.SYSTEM_DIVIDER:
            return "SYSTEM_DIVIDER";
        case Element.SYSTEM_TEXT:
            return "SYSTEM_TEXT";
        case Element.TAB_DURATION_SYMBOL:
            return "TAB_DURATION_SYMBOL";
        case Element.TBOX:
            return "TBOX";
        case Element.TEMPO_TEXT:
            return "TEMPO_TEXT";
        case Element.TEXT:
            return "TEXT";
        case Element.TEXTLINE:
            return "TEXTLINE";
        case Element.TEXTLINE_BASE:
            return "TEXTLINE_BASE";
        case Element.TEXTLINE_SEGMENT:
            return "TEXTLINE_SEGMENT";
        case Element.TIE:
            return "TIE";
        case Element.TIE_SEGMENT:
            return "TIE_SEGMENT";
        case Element.TIMESIG:
            return "TIMESIG";
        case Element.TREMOLO:
            return "TREMOLO";
        case Element.TREMOLOBAR:
            return "TREMOLOBAR";
        case Element.TRILL:
            return "TRILL";
        case Element.TRILL_SEGMENT:
            return "TRILL_SEGMENT";
        case Element.TUPLET:
            return "TUPLET";
        case Element.VBOX:
            return "VBOX";
        case Element.VIBRATO:
            return "VIBRATO";
        case Element.VIBRATO_SEGMENT:
            return "VIBRATO_SEGMENT";
        case Element.VOLTA:
            return "VOLTA";
        case Element.VOLTA_SEGMENT:
            return "VOLTA_SEGMENT";
        default:
            return "(Element." + (elementType + 0) + ")";
        }
    }

    /** signature: applyToSelectionOrScore(cb, ...args) */
    function applyToSelectionOrScore(cb) {
        var args = Array.prototype.slice.call(arguments, 1);
        var staveBeg;
        var staveEnd;
        var tickEnd;
        var rewindMode;
        var toEOF;

        var cursor = curScore.newCursor();
        cursor.rewind(Cursor.SELECTION_START);
        if (cursor.segment) {
            staveBeg = cursor.staffIdx;
            cursor.rewind(Cursor.SELECTION_END);
            staveEnd = cursor.staffIdx;
            if (!cursor.tick) {
                /*
                 * This happens when the selection goes to the
                 * end of the score — rewind() jumps behind the
                 * last segment, setting tick = 0.
                 */
                toEOF = true;
            } else {
                toEOF = false;
                tickEnd = cursor.tick;
            }
            rewindMode = Cursor.SELECTION_START;
        } else {
            /* no selection */
            staveBeg = 0;
            staveEnd = curScore.nstaves - 1;
            toEOF = true;
            rewindMode = Cursor.SCORE_START;
        }

        for (var stave = staveBeg; stave <= staveEnd; ++stave) {
            for (var voice = 0; voice < 4; ++voice) {
                cursor.staffIdx = stave;
                cursor.voice = voice;
                cursor.rewind(rewindMode);
                /*XXX https://musescore.org/en/node/301846 */
                cursor.staffIdx = stave;
                cursor.voice = voice;

                while (cursor.segment &&
                    (toEOF || cursor.tick < tickEnd)) {
                    if (cursor.element)
                        cb.apply(null,
                            [cursor].concat(args));
                    cursor.next();
                }
            }
        }
    }
    
    function dropLyrics(cursor, measureMap) {
        if (!cursor.element.lyrics)
            return;
        for (var i = 0; i < cursor.element.lyrics.length; ++i) {
            console.log(showPos(cursor, measureMap) + ": Lyric#" +
                i + " = " + cursor.element.lyrics[i].text);
            /* removeElement was added in 3.3.0 */
            removeElement(cursor.element.lyrics[i]);
        }
    }
    
    // Get a cursor pointing to the next note in the same voice and staff
    // at a given distance (in ticks), of given length and with or without
    // lyrics, if such a note exists
    function getCursorToNextNote(cursor,score,
        advance_by_ticks,nominal_duration_next_note,require_lyrics)
    {
                var second_cursor=score.newCursor();
                second_cursor.staffIdx=cursor.staffIdx;
                second_cursor.voice=cursor.voice;
                second_cursor.rewindToTick(cursor.tick+advance_by_ticks);
                second_cursor.staffIdx=cursor.staffIdx;
                second_cursor.voice=cursor.voice;
                var done=false;
                while (!done && second_cursor.segment &&
                    (second_cursor.tick == cursor.tick+advance_by_ticks)) {
                    if (second_cursor.element)
                    {
                        if (second_cursor.element.type == Element.CHORD  && second_cursor.element.duration.ticks==nominal_duration_next_note)
                        {
                           if(second_cursor.element.lyrics || !require_lyrics )
                            {
                                if(!require_lyrics || second_cursor.element.lyrics.length>0)
                                {
                                    
                                        done=true;
                                    
                                }
                            }
                        }
                        if(!done)
                        {
                            second_cursor.next();
                        }
                    }
                }
                if(done) { return second_cursor; }
                return null;
        
    }
    
    function span_names_two_notes(cursor, measureMap, doneMap,score){
        if (!cursor.element.lyrics)
            return;
        if (cursor.element.lyrics.length>0) {
            if(cursor.element.lyrics[0].text=="0.75") // 1/8 with . and the 1/16
            {
                var second_cursor=getCursorToNextNote(cursor,score,
                                division*0.75,division*0.25,true);
                if(second_cursor && second_cursor.element.lyrics[0].text=="double")
                {
                                        cursor.element.lyrics[0].text="sau";
                                        cursor.element.lyrics[0].syllabic = Lyrics.BEGIN;
                                        second_cursor.element.lyrics[0].text="te";
                                        second_cursor.element.lyrics[0].syllabic = Lyrics.END;
                    
                }
                
            } // end 1/8 with . and the 1/16
            
            
            if(cursor.element.lyrics[0].text=="1.5") // 1/4 with . and the 1/8
            {
                var second_cursor=getCursorToNextNote(cursor,score,
                    division*1.5,division*0.5,true);
                if(second_cursor && second_cursor.element.lyrics[0].text=="croche")
                {
                    cursor.element.lyrics[0].text="nooiire";
                    cursor.element.lyrics[0].syllabic = Lyrics.BEGIN;
                    second_cursor.element.lyrics[0].text="croche";
                    second_cursor.element.lyrics[0].syllabic = Lyrics.END;

                }
            } // end 1/4 with . and the 1/8
            
            if(cursor.element.lyrics[0].text=="croche") // 1/8 with a beam
            {
                if(cursor.element.beam)
                {
                    // only start when note on beat
                    // start tick
                        var beatMeasure=(cursor.tick-cursor.measure.firstSegment.tick)/division;
                        if(Math.round(beatMeasure)==beatMeasure)
                        {
                            var second_cursor=getCursorToNextNote(cursor,score,
                                division*0.5,division*0.5,true);
                            if(second_cursor && second_cursor.element.lyrics[0].text=="croche")
                            {
                                    cursor.element.lyrics[0].text="deux";
                                    second_cursor.element.lyrics[0].text="croches";
        
                            }
                        }
                    }
            } // end 1/8 linked with beam
            
            if(cursor.element.lyrics[0].text=="double") // 1/16 with a beam
            {
                if(cursor.element.beam)
                {
                    // only start when note on 1/2 beat
                    // start tick
                        var beatMeasure=(cursor.tick-cursor.measure.firstSegment.tick)/division;
                        if(Math.round(beatMeasure*2)==beatMeasure*2)
                        {
                            var second_cursor=getCursorToNextNote(cursor,score,
                                division*0.25,division*0.25,true);
                            if(second_cursor && second_cursor.element.lyrics[0].text=="double")
                            {
                                    cursor.element.lyrics[0].text="deux";
                                    second_cursor.element.lyrics[0].text="doubles";
        
                            }
                        }
                    }
            } // end 1/16 linked with beam
            
            
            
            if(cursor.element.lyrics[0].text=="croche") // triolets
            {
                if(cursor.element.beam)
                {
                        var second_cursor=getCursorToNextNote(cursor,score,
                                division/3,division*0.5,true);
                        if(second_cursor && second_cursor.element.lyrics[0].text=="croche")
                        {
                            var third_cursor=getCursorToNextNote(second_cursor,score,
                                division/3,division*0.5,true);
                            if(third_cursor && third_cursor.element.lyrics[0].text=="croche")
                            {
                                cursor.element.lyrics[0].text="tri";
                                second_cursor.element.lyrics[0].text="o";
                                third_cursor.element.lyrics[0].text="lets";
                                cursor.element.lyrics[0].syllabic = Lyrics.BEGIN;
                                second_cursor.element.lyrics[0].syllabic = Lyrics.MIDDLE;
                                third_cursor.element.lyrics[0].syllabic = Lyrics.END;
                            }
                        }
                    }
            } // end 1/16 linked with beam
            
            
            
        } // End has lyrics
        
        
        
        
    }
    
    
    function span_names_four_notes(cursor, measureMap, doneMap,score){
        if (!cursor.element.lyrics)
            return;
        if (cursor.element.lyrics.length>0)
        {
            // only start when note on beat
            // start tick
            var beatMeasure=(cursor.tick-cursor.measure.firstSegment.tick)/division;
            if(Math.round(beatMeasure)==beatMeasure)
            {
                if(cursor.element.lyrics[0].text=="deux" && cursor.element.duration.ticks==division*0.25) // 4 1/16
                {
                    var second_cursor=getCursorToNextNote(cursor,score,
                                division*0.25,division*0.25,true);
                    if(second_cursor && second_cursor.element.lyrics[0].text=="doubles")
                    {
                        var third_cursor=getCursorToNextNote(second_cursor,score,
                                division*0.25,division*0.25,true);
                        if(third_cursor && third_cursor.element.lyrics[0].text=="deux")
                        {
                            var fourth_cursor=getCursorToNextNote(third_cursor,score,
                                division*0.25,division*0.25,true);
                            if(fourth_cursor && fourth_cursor.element.lyrics[0].text=="doubles")
                            {
                                        cursor.element.lyrics[0].text="quat";
                                        cursor.element.lyrics[0].syllabic = Lyrics.BEGIN;
                                        second_cursor.element.lyrics[0].text="re";
                                        second_cursor.element.lyrics[0].syllabic = Lyrics.END;
                                        third_cursor.element.lyrics[0].text="doub";
                                        third_cursor.element.lyrics[0].syllabic = Lyrics.BEGIN;
                                        fourth_cursor.element.lyrics[0].text="les";
                                        fourth_cursor.element.lyrics[0].syllabic = Lyrics.END;
                            }
                        }
                    }
                }
            }
        } // End has lyrics
    }

    

    function labelBeat(cursor, measureMap, doneMap) {
        //console.log(showPos(cursor, measureMap) + ": " +
        //    nameElementType(cursor.element.type));
        if (cursor.element.type !== Element.CHORD)
            return;

        var t = cursor.segment.tick;
        if (doneMap[t])
            return;
        doneMap[t] = true;
        var m = measureMap[cursor.measure.firstSegment.tick];
        var b = "?";
        if (m && t >= m.tick && t < m.past) {
            //b = 1 + (t - m.tick) / m.ticksB;
            // theoretical_duration_ticks
            b= cursor.element.duration.ticks;
        }

        var text = newElement(Element.LYRICS);
        text.text = "" + primaryNoteNameFromTicks(b);

        if (text.text == "")
            return;
        text.verse = cursor.voice;
        cursor.element.add(text);
    }
    
    function primaryNoteNameFromTicks(tickDuration)
    {
        switch (tickDuration/division) {
            case 0.25:
                return "double";
            case 0.5:
                return "croche";
            case 1:
                return "noire";
            case 2:
                return "blanche";
            case 4:
                return "ronde";
        }
        return tickDuration/division;
    }
    
    onRun: {
        var measureMap = buildMeasureMap(curScore);
        var doneMap = {};
        if (removeElement)
            applyToSelectionOrScore(dropLyrics, measureMap,doneMap);
        doneMap = {};
        applyToSelectionOrScore(labelBeat, measureMap, doneMap);
        doneMap = {};
        applyToSelectionOrScore(span_names_two_notes, measureMap, doneMap,curScore);
        doneMap = {};
        applyToSelectionOrScore(span_names_four_notes, measureMap, doneMap,curScore);
        

        Qt.quit();
    }
}

