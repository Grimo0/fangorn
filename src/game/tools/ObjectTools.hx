package tools;

import dn.heaps.slib.HSprite;

class ObjectTools
{
	static public inline function isVisible(o : h2d.Object) : Bool
	{
		if (o.parent != null && o.visible) return isVisible(o.parent);
		return o.parent == null;
	}

	#if hlimgui
	static public function imguiDisplayChildren(o : h2d.Object, maxWidth : Float, maxHeight : Float)
	{
		var natArray = new hl.NativeArray<Single>(1);
		var drawList = ImGui.getWindowDrawList();
		var style : ImGuiStyle = ImGui.getStyle();

		@:privateAccess
		for (idx => c in o.children)
		{
			ImGui.pushID('$idx');

			var ref = new hl.Ref(c.visible);
			if (ImGui.checkbox('##visible', ref))
				c.visible = ref.get();
			ImGui.sameLine();
			if (!c.visible)
				ImGui.pushStyleColor(ImGuiCol.Text, ImGui.getColorU32(ImGuiCol.TextDisabled));
			ImGui.text('$c');

			if (ImGui.isItemActive() || ImGui.isItemHovered())
			{
				ImGui.pushClipRect({x: 0, y: 0}, {x: App.ME.s2d.width, y: App.ME.s2d.height}, false);
				var lineColor = ImGui.getStyleColorVec4(PlotLines).toColor();
				var size = c.getBounds();
				var leftTopPoint = new Point(size.xMin, size.yMin);
				var rightBotPoint = new Point(size.xMax, size.yMax);
				drawList.addRect(leftTopPoint, rightBotPoint, lineColor, 0, ImDrawFlags.RoundCornersAll, 2);
				ImGui.popClipRect();

				try
				{
					var frameData = cast(c, HSprite).frameData;
					if (frameData != null)
						ImGui.setTooltip(frameData.toString());
				} catch (e)
				{
					ImGui.setTooltip('${M.round(size.width)} x ${M.round(size.height)}');
				}
			}

			var showChildren = false;
			if (c.children.length > 0)
			{
				ImGui.alignTextToFramePadding();
				showChildren = ImGui.treeNodeEx('###$c$idx');
				ImGui.sameLine();
				ImGui.pushItemWidth(((cast ImGui.getContentRegionAvail()).x - Std.int(style.IndentSpacing) - 4) / 5);
			} else
			{
				ImGui.indent(ImGui.getFrameHeight());
				ImGui.pushItemWidth(((cast ImGui.getContentRegionAvail()).x - Std.int(style.IndentSpacing) - 4) / 5);
			}

			natArray[0] = c.x;
			if (ImGui.sliderFloat('##x', natArray, -maxWidth, maxWidth, 'x %.0f'))
				c.x = natArray[0];
			if (ImGui.isItemActive() || ImGui.isItemHovered())
				ImGui.setTooltip('${Std.int(c.x / maxWidth * 10000) / 100}%');
			ImGui.sameLine();
			natArray[0] = c.y;
			if (ImGui.sliderFloat('##y', natArray, -maxHeight, maxHeight, 'y %.0f'))
				c.y = natArray[0];
			if (ImGui.isItemActive() || ImGui.isItemHovered())
				ImGui.setTooltip('${Std.int(c.y / maxHeight * 10000) / 100}%');
			ImGui.sameLine();
			natArray[0] = c.scaleX;
			if (ImGui.sliderFloat('##sc', natArray, 0, 2, 'sc %.2f'))
				c.setScale(natArray[0]);
			if (ImGui.isItemActive() || ImGui.isItemHovered())
				ImGui.setTooltip('${natArray[0]}');
			ImGui.sameLine();
			natArray[0] = c.rotation * M.RAD_DEG;
			if (ImGui.sliderFloat('##rotation', natArray, 0, 360, 'r %.0f'))
				c.rotation = natArray[0] * M.DEG_RAD;
			if (ImGui.isItemActive() || ImGui.isItemHovered())
				ImGui.setTooltip('${Std.int(natArray[0] * 100) / 100}°');
			ImGui.sameLine();
			natArray[0] = c.alpha;
			if (ImGui.sliderFloat('##alpha', natArray, 0, 1, 'a %.2f'))
				c.alpha = natArray[0];
			if (ImGui.isItemActive() || ImGui.isItemHovered())
				ImGui.setTooltip('${c.alpha * 100}%');

			if (!c.visible)
				ImGui.popStyleColor();

			ImGui.popItemWidth();

			if (showChildren)
			{
				if (Std.isOfType(c, h2d.Text))
				{
					var t = cast(c, h2d.Text);
					/* var a = [for (font in Assets.fonts.iterator()) font];
					ImGui.comboWithArrows('Font', a.search((f : h2d.Font) -> f.name == t.font.name), a,
						(i : Int) -> if (i >= 0) '${a[i].name}#${a[i].tilePath}' else '',
						(i : Int) ->
						{
							t.font = a[i];
						}
					); */
					@:privateAccess natArray[0] = t.font.lineHeight;
					if (ImGui.sliderFloat('Line Height', natArray, 0, 80, '%.0f'))
					{
						@:privateAccess t.font.lineHeight = natArray[0];
						t.needsRebuild = true;
					}
					@:privateAccess natArray[0] = t.font.offsetX;
					if (ImGui.sliderFloat('OffsetX', natArray, -20, 20, '%.0f'))
					{
						t.font.setOffset(natArray[0], t.font.offsetY);
						t.needsRebuild = true;
					}
					@:privateAccess natArray[0] = t.font.offsetY;
					if (ImGui.sliderFloat('OffsetY', natArray, -20, 20, '%.0f'))
					{
						t.font.setOffset(t.font.offsetX, natArray[0]);
						t.needsRebuild = true;
					}
				}

				var cursor : ImVec2 = ImGui.getCursorScreenPos();

				imguiDisplayChildren(c, maxWidth, maxHeight);

				var cursor2 : ImVec2 = ImGui.getCursorScreenPos();
				cursor.x -= 4;
				cursor2.x -= 4;
				cursor2.y -= 4;

				drawList.addLine(cursor, cursor2, ImGui.getStyleColorVec4(Separator).toColor());

				ImGui.treePop();
			} else if (c.children.length == 0)
				ImGui.unindent(ImGui.getFrameHeight());
			ImGui.popID();
		}
	}
	#end
}