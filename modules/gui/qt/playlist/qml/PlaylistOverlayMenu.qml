/*****************************************************************************
 * Copyright (C) 2020 VLC authors and VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
import QtQuick 2.11
import QtQuick.Controls 2.4

import org.videolan.vlc 0.1

import "qrc:///widgets/" as Widgets
import "qrc:///style/"

Widgets.OverlayMenu {
    id: overlayMenu

    Action {
        id: playAction
        text: I18n.qtr("Play")
        onTriggered: mainPlaylistController.goTo(root.model.getSelection()[0], true)
        property string fontIcon: VLCIcons.play
    }

    Action {
        id: streamAction
        text: I18n.qtr("Stream")
        onTriggered: DialogsProvider.streamingDialog(root.model.getSelection().map(function(i) { return root.model.itemAt(i).url; }), false)
        property string fontIcon: VLCIcons.stream
    }

    Action {
        id: saveAction
        text: I18n.qtr("Save")
        onTriggered: DialogsProvider.streamingDialog(root.model.getSelection().map(function(i) { return root.model.itemAt(i).url; }))
    }

    Action {
        id: infoAction
        text: I18n.qtr("Information")
        onTriggered: DialogsProvider.mediaInfoDialog(root.model.itemAt(root.model.getSelection()[0]))
        icon.source: "qrc:/menu/info.svg"
    }

    Action {
        id: exploreAction
        text: I18n.qtr("Show Containing Directory")
        onTriggered: mainPlaylistController.explore(root.model.itemAt(root.model.getSelection()[0]))
        icon.source: "qrc:/type/folder-grey.svg"
    }

    Action {
        id: addFileAction
        text: I18n.qtr("Add File...")
        onTriggered: DialogsProvider.simpleOpenDialog(false)
        property string fontIcon: VLCIcons.add
    }

    Action {
        id: addDirAction
        text: I18n.qtr("Add Directory...")
        onTriggered: DialogsProvider.PLAppendDir()
        property string fontIcon: VLCIcons.add
    }

    Action {
        id: addAdvancedAction
        text: I18n.qtr("Advanced Open...")
        onTriggered: DialogsProvider.PLAppendDialog()
        property string fontIcon: VLCIcons.add
    }

    Action {
        id: savePlAction
        text: I18n.qtr("Save Playlist to File...")
        onTriggered: DialogsProvider.savePlayingToPlaylist();
    }

    Action {
        id: clearAllAction
        text: I18n.qtr("Clear Playlist")
        onTriggered: mainPlaylistController.clear()
        icon.source: "qrc:/toolbar/clear.svg"
    }

    Action {
        id: selectAllAction
        text: I18n.qtr("Select All")
        onTriggered: root.model.selectAll()
    }

    Action {
        id: shuffleAction
        text: I18n.qtr("Shuffle Playlist")
        onTriggered: mainPlaylistController.shuffle()
        property string fontIcon: VLCIcons.shuffle_on
    }

    Action {
        id: sortAction
        text: I18n.qtr("Sort")
        property alias model: overlayMenu.sortMenu
    }

    Action {
        id: selectTracksAction
        text: I18n.qtr("Select Tracks")
        onTriggered: root.mode = PlaylistListView.Mode.Select
    }

    Action {
        id: moveTracksAction
        text: I18n.qtr("Move Selection")
        onTriggered: root.mode = PlaylistListView.Mode.Move
    }

    Action {
        id: deleteAction
        text: I18n.qtr("Remove Selected")
        onTriggered: listView.onDelete()
    }

    property var rootMenu: ({

                                title: I18n.qtr("Playlist Menu"),
                                entries: [
                                    playAction,
                                    streamAction,
                                    saveAction,
                                    infoAction,
                                    exploreAction,
                                    addFileAction,
                                    addDirAction,
                                    addAdvancedAction,
                                    savePlAction,
                                    clearAllAction,
                                    selectAllAction,
                                    shuffleAction,
                                    sortAction,
                                    selectTracksAction,
                                    moveTracksAction,
                                    deleteAction
                                ]
                            })

    property var rootMenu_PLEmpty: ({
                                        title: I18n.qtr("Playlist Menu"),
                                        entries: [
                                            addFileAction,
                                            addDirAction,
                                            addAdvancedAction
                                        ]
                                    })

    property var rootMenu_noSelection: ({
                                            title: I18n.qtr("Playlist Menu"),
                                            entries: [
                                                addFileAction,
                                                addDirAction,
                                                addAdvancedAction,
                                                savePlAction,
                                                clearAllAction,
                                                sortAction,
                                                selectTracksAction
                                            ]
                                        })

    model: {
        if (root.model.count === 0)
            rootMenu_PLEmpty
        else if (root.model.selectedCount === 0)
            rootMenu_noSelection
        else
            rootMenu
    }

    // Sort menu:

    property var sortMenu: ({
                                title: I18n.qtr("Sort Menu"),
                                entries: []
                            })

    Component {
        id: sortActionDelegate

        Action {
            property int key: undefined
            readonly property string marking: {
                if (key === mainPlaylistController.sortKey) {
                    return (mainPlaylistController.sortOrder === PlaylistControllerModel.SORT_ORDER_ASC ? "↓" : "↑")
                }
                else {
                    return null
                }
            }
            readonly property bool tickMark: (key === mainPlaylistController.sortKey)

            onTriggered: mainPlaylistController.sort(key)
        }
    }

    Repeater {
        model: mainPlaylistController.sortKeyTitleList

        delegate: Loader {
            asynchronous: true
            sourceComponent: sortActionDelegate

            onLoaded: {
                item.text = modelData.title
                item.key = modelData.key
                overlayMenu.sortMenu.entries.push(item)
            }
        }
    }
}
