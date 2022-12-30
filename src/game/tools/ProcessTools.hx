package tools;

import dn.Process;

class ProcessTools
{
	#if hlimgui
	static public function imguiDefaultDisplay(p : Process, beforeRoot : Void->Void = null,
		afterChildren : Void->Void = null, maxWidth : Float, maxHeight : Float)
	{
		if (p.root == null || p.isPaused() || !Boot.ME.imGuiActive || !Boot.ME.imGuiDebugOpen) return;

		if (!ImGui.collapsingHeader(p.getDisplayName(), DefaultOpen))
			return;

		ImGui.pushID(p.getDisplayName());

		if (beforeRoot != null)
			beforeRoot();

		var natArray = new hl.NativeArray<Single>(1);
		var ref : hl.Ref<Bool>;

		ImGui.text('Root:');

		ref = new hl.Ref(p.root.visible);
		if (ImGui.checkbox("##RootVisible", ref))
			p.root.visible = ref.get();
		ImGui.sameLine(0, 3);
		ImGui.pushItemWidth(ImGui.getContentRegionAvail().x / 4);
		natArray[0] = p.root.x;
		if (ImGui.sliderFloat('##RootX', natArray, 0, maxWidth, 'x %.0f'))
			p.root.x = natArray[0];
		ImGui.sameLine(0, 3);
		natArray[0] = p.root.y;
		if (ImGui.sliderFloat('##RootY', natArray, 0, maxHeight, 'y %.0f'))
			p.root.y = natArray[0];
		ImGui.sameLine(0, 3);
		natArray[0] = p.root.scaleX;
		if (ImGui.sliderFloat('##RootScalex', natArray, 0, 2, 'sX %.2f'))
			p.root.scaleX = natArray[0];
		ImGui.sameLine(0, 3);
		natArray[0] = p.root.scaleY;
		if (ImGui.sliderFloat('##RootScaley', natArray, 0, 2, 'sY %.2f'))
			p.root.scaleY = natArray[0];
		ImGui.popItemWidth();

		if (ImGui.treeNodeEx('Children'))
		{
			if (ImGui.beginChild('Children', new Point((cast ImGui.getContentRegionAvail()).x, 250)))
			{
				p.root.imguiDisplayChildren(maxWidth, maxHeight);
			}
			ImGui.endChild();
			ImGui.treePop();
		}

		if (afterChildren != null)
			afterChildren();

		p.cd.imguiDisplayList();
		p.ucd.imguiDisplayList('UCooldown');
		p.tw.imguiDisplayList();
		p.delayer.imguiDisplayList();
		p.udelayer.imguiDisplayList('UDelayer');

		ImGui.popID();
	}
	#end
}