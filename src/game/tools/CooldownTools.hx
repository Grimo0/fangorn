package tools;

class CooldownTools
{
	#if hlimgui
	static public function imguiDisplayList(cd : dn.Cooldown, name : String = 'Cooldown')
	{
		if (ImGui.treeNodeEx('$name###$name'))
		{
			ImGui.sameLine(ImGui.getContentRegionAvail().x - 45);
			ImGui.textDisabled('${cd.baseFps}fps');
			ImGui.columns(2, name, false);
			for (cdInst in @:privateAccess cd.cds)
			{
				ImGui.pushIDInt(cdInst.k >>> 22);

				ImGui.alignTextToFramePadding();
				ImGui.text(cdInst.toString());
				ImGui.nextColumn();

				ImGui.progressBar(cdInst.frames / cdInst.initial, '${Std.int(cdInst.frames / cd.baseFps * 10) / 10}/${Std.int(cdInst.initial / cd.baseFps * 10) / 10}s');
				ImGui.nextColumn();

				ImGui.popID();
			}
			ImGui.columns(1);
			ImGui.treePop();
		} else
		{
			ImGui.sameLine(ImGui.getContentRegionAvail().x - 45);
			ImGui.textDisabled('${cd.baseFps}fps');
		}
	}
	#end
}