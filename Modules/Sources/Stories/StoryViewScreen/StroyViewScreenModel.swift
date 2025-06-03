//
//  StroyViewScreenModel.swift
//  Instagram
//
//  Created by Mihai Cristescu on 28.05.2025.
//

import Dependencies
import Observation

@MainActor
@Observable
final class StoryViewScreenModel {
    let story: Story

    init(story: Story) {
        self.story = story
    }
}
