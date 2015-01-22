-- Users, tweets, and hashtags. The actual tables that store data. --

CREATE TABLE IF NOT EXISTS user (
	id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(50),
    private TINYINT(1),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tweet (
	id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	user_id INT(10) UNSIGNED NOT NULL,
	text VARCHAR(141),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS hashtag (
	id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	tag VARCHAR(140),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Relationships between everyone for searching and following. --

-- Stores users at whom a tweet is tweeted (for faster displaying).
CREATE TABLE IF NOT EXISTS tweet_to (
	tweet_id INT(10) UNSIGNED NOT NULL,
	user_id INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`tweet_id`, `user_id`)
) ENGINE=InnoDB;

ALTER TABLE `tweet_to`
ADD CONSTRAINT `tweet_tweet` FOREIGN KEY (`tweet_id`) REFERENCES `tweet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT `tweet_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- Stores relationship between a tweet and its hashtags (for faster searching).
CREATE TABLE IF NOT EXISTS tweet_hashtag (
	tweet_id INT UNSIGNED NOT NULL,
	hashtag_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (`tweet_id`, `hashtag_id`)
) ENGINE=InnoDB;

ALTER TABLE `tweet_hashtag`
ADD CONSTRAINT `tagged_tweet` FOREIGN KEY (`tweet_id`) REFERENCES `tweet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT `tweet_tag` FOREIGN KEY (`hashtag_id`) REFERENCES `hashtag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- Stores relationships between followers
CREATE TABLE IF NOT EXISTS followed (
	followed_id INT UNSIGNED NOT NULL,
	follower_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (`followed_id`, `follower_id`)
) ENGINE=InnoDB;

ALTER TABLE `followed`
ADD CONSTRAINT `followed_user` FOREIGN KEY (`followed_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT `follower` FOREIGN KEY (`follower_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;