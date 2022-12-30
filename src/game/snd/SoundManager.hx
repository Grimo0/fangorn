package snd;

import hxd.snd.Channel;
import hxd.snd.ChannelGroup;

class SoundManager
{
	public static var ME : SoundManager;

	public var musicChannelGroup : ChannelGroup;
	public var soundChannelGroup : ChannelGroup;

	var musicsPlaying : Array<Channel>;
	var soundsPlaying : Array<Channel>;

	public var masterVolume(get, set) : Float;
	public inline function get_masterVolume()
	{
		var sndManager = hxd.snd.Manager.get();
		return sndManager.masterVolume;
	}
	public inline function set_masterVolume(v : Float)
	{
		var sndManager = hxd.snd.Manager.get();
		App.ME.tw.complete(sndManager.masterVolume);
		sndManager.masterVolume = v;
		return v;
	}

	public var musicVolume(get, set) : Float;
	public inline function get_musicVolume() return musicChannelGroup.volume;
	public inline function set_musicVolume(v : Float)
	{
		musicChannelGroup.volume = v;
		return v;
	}
	public var soundVolume(get, set) : Float;
	public inline function get_soundVolume() return soundChannelGroup.volume;
	public inline function set_soundVolume(v : Float) return soundChannelGroup.volume = v;

	public function new()
	{
		if (ME != null)
			throw "GameSave already instanciated.";
		ME = this;

		hxd.snd.Manager.get(); // force sound manager init on startup to avoid a freeze on first sound playback (because OpenAL takes time)
		hxd.Timer.skip(); // needed to ignore heavy Sound manager init frame

		musicChannelGroup = new ChannelGroup('music');
		soundChannelGroup = new ChannelGroup('sound');

		musicsPlaying = new Array();
		soundsPlaying = new Array();
	}

	public function fadeTo(volume : Float, milliSeconds : Int, ?onEnd)
	{
		var sndManager = hxd.snd.Manager.get();
		var tween = App.ME.tw.createMs(sndManager.masterVolume, volume, milliSeconds);
		if (onEnd != null)
			tween.end(onEnd);
	}

	public function stopAll()
	{
		var sndManager = hxd.snd.Manager.get();
		sndManager.stopAll();
		musicsPlaying.resize(0);
		soundsPlaying.resize(0);
	}

	public function pauseAll()
	{
		for (channel in musicsPlaying)
		{
			channel.pause = true;
		}
		for (channel in soundsPlaying)
		{
			channel.pause = true;
		}
	}

	public function resumeAll()
	{
		for (channel in musicsPlaying)
		{
			channel.pause = false;
		}
		for (channel in soundsPlaying)
		{
			channel.pause = false;
		}
	}

	public function getMusicPlaying(name : String) : Channel
	{
		for (channel in musicsPlaying)
		{
			var path = haxe.io.Path.withoutExtension(channel.sound.name);
			var lastDot = path.lastIndexOf(".");
			var filename = lastDot < 0 ? path : path.substr(0, lastDot);
			if (filename == name)
				return channel;
		}
		return null;
	}

	public function getSoundPlaying(name : String) : Channel
	{
		for (channel in soundsPlaying)
		{
			var path = haxe.io.Path.withoutExtension(channel.sound.name);
			var lastDot = path.lastIndexOf(".");
			var filename = lastDot < 0 ? path : path.substr(0, lastDot);
			if (filename == name)
				return channel;
		}
		return null;
	}

	public function fadeAndStopMusic(name : String, fadeTimeS = 1.)
	{
		for (channel in musicsPlaying)
		{
			var path = haxe.io.Path.withoutExtension(channel.sound.name);
			var lastDot = path.lastIndexOf(".");
			var filename = lastDot < 0 ? path : path.substr(0, lastDot);
			if (filename == name)
			{
				channel.fadeTo(0, fadeTimeS, () ->
				{
					channel.stop();
					musicsPlaying.remove(channel);
				});
			}
		}
	}

	public function fadeAndStopSound(name : String, fadeTimeS = 1.)
	{
		for (channel in soundsPlaying)
		{
			var path = haxe.io.Path.withoutExtension(channel.sound.name);
			var lastDot = path.lastIndexOf(".");
			var filename = lastDot < 0 ? path : path.substr(0, lastDot);
			if (filename == name)
			{
				channel.fadeTo(0, fadeTimeS, () ->
				{
					channel.stop();
					soundsPlaying.remove(channel);
				});
			}
		}
	}

	public function stopMusics(fadeTimeS : Float)
	{
		for (music in musicsPlaying)
		{
			music.fadeTo(0, fadeTimeS, () ->
			{
				music.stop();
				musicsPlaying.remove(music);
			});
		}
	}

	public function stopSounds(fadeTimeS : Float)
	{
		for (sound in soundsPlaying)
		{
			sound.fadeTo(0, fadeTimeS, () ->
			{
				sound.stop();
				soundsPlaying.remove(sound);
			});
		}
	}

	public function playMusic(name : String, loop : Bool = true, volume : Float = 1.)
	{
		var music = Assets.musics.get(name);
		if (music == null) return null;
		var channel = music.play(loop, volume, musicChannelGroup);
		musicsPlaying.push(channel);
		channel.onEnd = () ->
		{
			if (!channel.loop)
				musicsPlaying.remove(channel);
		};
		return channel;
	}

	public function playSound(name : String, loop : Bool = false, volume : Float = 1., rate : Float = 1.)
	{
		var sound = Assets.sounds.get(name);
		if (sound == null) return null;
		var channel = sound.play(loop, volume, soundChannelGroup);
		if (rate != 1.)
			channel.addEffect(new hxd.snd.effect.Pitch(rate));
		soundsPlaying.push(channel);
		channel.onEnd = () ->
		{
			if (!channel.loop)
				soundsPlaying.remove(channel);
		};
		return channel;
	}

	public function playSound2(sound : hxd.res.Sound, loop : Bool = false, volume : Float = 1., rate : Float = 1.)
	{
		if (sound == null) return null;
		var channel = sound.play(loop, volume, soundChannelGroup);
		if (rate != 1.)
			channel.addEffect(new hxd.snd.effect.Pitch(rate));
		soundsPlaying.push(channel);
		channel.onEnd = () ->
		{
			if (!channel.loop)
				soundsPlaying.remove(channel);
		};
		return channel;
	}

	#if hlimgui
	@:access(hxd.snd.Manager)
	public function updateImGui()
	{
		var natArray = new hl.NativeArray<Single>(1);
		var ref : hl.Ref<Bool>;

		var sndManager = hxd.snd.Manager.get();

		ImGui.pushItemWidth(ImGui.getContentRegionAvail().x);
		natArray[0] = sndManager.masterVolume;
		if (ImGui.sliderFloat('##masterVolume', natArray, 0., 1., 'master %.2f'))
			sndManager.masterVolume = natArray[0];
		natArray[0] = musicVolume;
		if (ImGui.sliderFloat('##musicVolume', natArray, 0., 1., 'music %.2f'))
			musicVolume = natArray[0];
		natArray[0] = soundVolume;
		if (ImGui.sliderFloat('##soundVolume', natArray, 0., 1., 'sound %.2f'))
			soundVolume = natArray[0];
		ImGui.popItemWidth();

		function displayChannel(c : Channel, group : ChannelGroup)
		{
			if (c.next != null)
				displayChannel(c.next, group);
			if (c.channelGroup != group) return;
			ImGui.pushID(c.sound.name);

			ImGui.alignTextToFramePadding();
			ImGui.text(c.sound.name);
			ImGui.nextColumn();

			ImGui.pushItemWidth(ImGui.getColumnWidth());
			natArray[0] = c.volume;
			if (ImGui.sliderFloat('##volume', natArray, 0., 1., 'V %.2f'))
				c.volume = natArray[0];
			ImGui.popItemWidth();
			ImGui.nextColumn();

			ImGui.pushItemWidth(ImGui.getColumnWidth());
			if (ImGui.button("S ", new Point(ImGui.getColumnWidth(), 0)))
			{
				c.stop();
				if (group == musicChannelGroup)
					musicsPlaying.remove(c);
				if (group == soundChannelGroup)
					soundsPlaying.remove(c);
			}
			ImGui.popItemWidth();
			ImGui.nextColumn();

			ImGui.progressBar(c.position / c.duration, '${Std.int(c.position * 10) / 10}/${Std.int(c.duration * 10) / 10}s');
			if (ImGui.isItemHovered())
				ImGui.setTooltip('${Std.int(c.position * 10) / 10}/${Std.int(c.duration * 10) / 10}s');
			ImGui.nextColumn();

			ImGui.popID();
		}

		ImGui.selectable('Musics', true);
		ImGui.columns(4, 'Musics', false);
		ImGui.setColumnWidth(0, M.fclamp(200, ImGui.getContentRegionAvail().x * 1 / 3, ImGui.getContentRegionAvail().x * 3 / 5));
		ImGui.setColumnWidth(1, M.fclamp(50, ImGui.getContentRegionAvail().x * 1 / 6, ImGui.getContentRegionAvail().x * 1 / 3));
		ImGui.setColumnWidth(2, 18);
		if (sndManager.channels != null)
			displayChannel(sndManager.channels, musicChannelGroup);
		for (music in musicsPlaying)
		{
			if (music.isReleased())
				displayChannel(music, musicChannelGroup);
		}
		ImGui.columns(1);

		ImGui.selectable('Sounds', true);
		ImGui.columns(4, 'Sounds', false);
		ImGui.setColumnWidth(0, M.fclamp(200, ImGui.getContentRegionAvail().x * 1 / 3, ImGui.getContentRegionAvail().x * 3 / 5));
		ImGui.setColumnWidth(1, M.fclamp(50, ImGui.getContentRegionAvail().x * 1 / 6, ImGui.getContentRegionAvail().x * 1 / 3));
		ImGui.setColumnWidth(2, 18);
		if (sndManager.channels != null)
			displayChannel(sndManager.channels, soundChannelGroup);
		ImGui.pushStyleColor(ImGuiCol.Text, ImGui.colorConvertFloat4ToU32({x: 1.00, y: 0.00, z: 0.00, w: 1.0}));
		for (sound in soundsPlaying)
		{
			if (sound.isReleased())
				displayChannel(sound, soundChannelGroup);
		}
		ImGui.popStyleColor();
		ImGui.columns(1);
	}
	#end
}