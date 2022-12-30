package tools;

import dn.Delayer;

class DelayerTools
{
	#if hlimgui
	@:access(dn.Delayer)
	static public function imguiDisplayList(delayer : Delayer, name : String = 'Delayer')
	{
		if (ImGui.treeNodeEx('$name###$name'))
		{
			ImGui.sameLine(ImGui.getContentRegionAvail().x - 45);
			ImGui.textDisabled('${delayer.fps}fps');
			ImGui.columns(2, name, false);
			for (i in 0...delayer.delays.length)
			{
				var delay = delayer.delays[i];
				ImGui.pushID('$name.$i');

				ImGui.alignTextToFramePadding();
				if (delay.id != null)
					ImGui.text(delay.id);
				else
					ImGui.text('${delay.cb}');
				ImGui.nextColumn();

				ImGui.text('${delay.t}s');
				ImGui.nextColumn();

				ImGui.popID();
			}
			ImGui.columns(1);
			ImGui.treePop();
		} else
		{
			ImGui.sameLine(ImGui.getContentRegionAvail().x - 45);
			ImGui.textDisabled('${delayer.fps}fps');
		}
	}
	#end
}