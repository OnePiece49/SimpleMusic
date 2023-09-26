//
//  AssetConstant.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import UIKit

enum AssetConstant {
    // For Home
    static let ic_home_unselect = "ic_home_unselect"
    static let ic_files_unselect = "ic_files_unselect"
    static let ic_import_unselect = "ic_import_unselect"
    static let ic_setting_unselect = "ic_setting_unselect"
    static let ic_home_select = "ic_home_select"
    static let ic_files_select = "ic_files_select"
    static let ic_import_select = "ic_import_select"
    static let ic_setting_select = "ic_setting_select"
    
    // Base import
    static let ic_back = "ic_back"
    static let ic_download = "ic_download"
    
    // For ImportVC
    static let ic_box = "ic_box"
    static let ic_dropBox = "ic_dropBox"
    static let ic_google_drive = "ic_google_drive"
    static let ic_onedrive = "ic_onedrive"

    // For SettingVC
    static let ic_notification = "ic_notification"
    static let ic_share_app = "ic_share_app"
    static let ic_rate_app = "ic_rate_app"
    static let ic_term_of_service = "ic_term_of_service"
    static let ic_contact_us = "ic_contact_us"

    
    // For My Files
    static let ic_audio = "ic_audio"
    static let ic_downloaded = "ic_downloaded"
    static let ic_favourite = "ic_favourite"
    static let ic_playlist = "ic_playlist"
    static let ic_youtube = "ic_youtube"
    
    
    // For Imported Detail
    static let ic_thumbnail_default = "luffy"
    static let ic_more = "ic_more"
    
    // For PlayerVC
    static let ic_add_song = "ic_add_song"
    static let ic_current_playlist = "ic_current_playlist"
    static let ic_heart = "ic_heart"
    static let ic_share = "ic_share"
    static let ic_convert = "ic_convert"
    static let ic_not_replay = "ic_not_replay"
    static let ic_replay_ones = "ic_play_ones"
    static let ic_replay_all = "ic_replay_all"
    static let ic_not_random = "ic_not_random"
    static let ic_next = "ic_next"
    static let ic_back_song = "ic_back_song"
    static let ic_is_pausing = "ic_is_pausing"
    static let ic_heart_fill = "ic_heart_fill"
    static let ic_random_selected = "ic_random_selected"
    static let ic_is_playing = "ic_is_playing"
    static let ic_choose_image = "ic_choose_image"
    static let ic_make_mini = "ic_make_mini"
    static let ic_download_player = "ic_download_player"
    
    // For MiniPlayerView
    static let ic_mini_play = "ic_mini_play"
    static let ic_mini_next = "ic_mini_next"
    static let ic_mini_back = "ic_mini_back"
    static let ic_mini_playing = "ic_mini_playing"
    static let ic_progress = "ic_progress"
    
    
    
    // For AudioConvertedVC
    static let ic_audio_converted = "ic_audio_converted"
    
    // For HomeVC
    static let ic_search = "ic_search"
    
}


enum AppConstant {

	static let kDropboxUrlScheme = "db-11wx3wbn49i55it"
	static let kOnedriveUrlScheme = "msauth.ducanh.LAS-MUSIC-009"

    enum GoogleDrive {
        static let client_id = "317966056645-br36i6l97i4rnj48omaqf8bi8dr7kc7a.apps.googleusercontent.com"
        static let api_key = "AIzaSyALxclPiwe4aBjfc4NrWVnssDyDMym9i88"
        static let root_type_video_audio = "(mimeType = 'video/mp4' or mimeType = 'audio/mpeg')"
        static let field_requets = "files(id,name,mimeType,modifiedTime,fileExtension,size,iconLink, thumbnailLink, hasThumbnail, videoMediaMetadata, viewersCanCopyContent),nextPageToken"
        static let root_type_all = "(mimeType = 'image/jpeg' or mimeType = 'image/png' or mimeType = 'application/pdf' or mimeType = 'video/mp4' or mimeType = 'audio/mpeg')"
    }

    enum Box {
        static let client_id = "oxek9vpmkwwfwf9a1pb23pfqkwprnmqo"
        static let client_secret = "ayjsrjYqRlYZlCZAangHemWJKAMcOh1q"
    }

    enum Dropbox {
        static let app_key = "11wx3wbn49i55it"
    }

	enum OneDrive {
		static let client_id = "0ccfe7b8-a178-46bc-be4f-9a5c8f3f8539"
		static let redict_uri = "msauth.ducanh.LAS-MUSIC-009://auth"
		static let authority = "https://login.microsoftonline.com/common"
		static let graph_endpoint = "https://graph.microsoft.com/"
		static let audio_video_file_request = "file ne null and (file/mimeType eq 'audio/mpeg' or file/mimeType eq 'video/mp4')"
	}
    
}
