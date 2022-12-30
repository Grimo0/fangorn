package tools;

class TweenieTools
{
	#if hlimgui
	@:access(dn.Tweenie)
	static public function imguiDisplayList(tw : dn.Tweenie, name : String = 'Tweenie')
	{
		if (ImGui.treeNodeEx('$name###$name'))
		{
			ImGui.sameLine(ImGui.getContentRegionAvail().x - 45);
			ImGui.textDisabled('${tw.baseFps}fps');
			ImGui.columns(3, name, false);
			for (t in tw.allTweens)
			{
				ImGui.pushID('${t.getter}');

				ImGui.alignTextToFramePadding();
				ImGui.text('${t.type}');
				ImGui.nextColumn();

				ImGui.alignTextToFramePadding();
				ImGui.textDisabled('from');
				ImGui.sameLine();
				ImGui.text('${t.from}');
				ImGui.nextColumn();

				ImGui.alignTextToFramePadding();
				ImGui.textDisabled('to');
				ImGui.sameLine();
				ImGui.text('${t.to}');
				ImGui.nextColumn();

				ImGui.alignTextToFramePadding();
				ImGui.textDisabled('delay');
				ImGui.sameLine();
				ImGui.text('${t.delay}|${Std.int(t.delay / tw.baseFps * 10) / 10}s');
				// ImGui.progressBar(t.delay / t.delayInitial, 'delay ${Std.int(t.delay / tw.baseFps * 10) / 10}/${Std.int(t.delayInitial / tw.baseFps * 10) / 10}s');
				ImGui.nextColumn();

				ImGui.progressBar(t.n, 'n ${Std.int(t.n / t.speed / tw.baseFps * 10) / 10}/${Std.int(1 / t.speed / tw.baseFps * 10) / 10}s');
				ImGui.nextColumn();

				ImGui.progressBar(t.ln, 'ln ${Std.int(t.ln / t.speed / tw.baseFps * 10) / 10}/${Std.int(1 / t.speed / tw.baseFps * 10) / 10}s');
				ImGui.nextColumn();

				ImGui.popID();
			}
			ImGui.columns(1);
			ImGui.treePop();
		} else
		{
			ImGui.sameLine(ImGui.getContentRegionAvail().x - 45);
			ImGui.textDisabled('${tw.baseFps}fps');
		}
	}
	#end
}