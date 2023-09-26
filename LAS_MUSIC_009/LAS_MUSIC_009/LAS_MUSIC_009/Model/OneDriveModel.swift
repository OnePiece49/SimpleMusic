//
//  OneDriveModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 15/08/2023.
//

import Foundation

struct OneDriveResponse: Codable {
	var value: [OneDriveModel]
}

struct OneDriveModel: Codable {
	var id: String
	var name: String
	var size: Double
	var downloadURL: String?
	var file: OneDriveFile?
	var audio: OneDriveAudio?
	var video: OneDriveVideo?
	var thumbnails: [OneDriveThumbnail]?

	private enum CodingKeys: String, CodingKey {
		case downloadURL = "@microsoft.graph.downloadUrl"
		case id, name, size, file, audio, video, thumbnails
	}
}

struct OneDriveFile: Codable {
	var mimeType: String
}

struct OneDriveVideo: Codable {
	var duration: Double
}

struct OneDriveAudio: Codable {
	var artist: String?
	var duration: Double
}

struct OneDriveThumbnail: Codable {
	var id: String
	var small: OneDriveThumbnailDetail
}

struct OneDriveThumbnailDetail: Codable {
	var url: String
}
