package tools;

typedef FPath = Path<Float>;
typedef IPath = Path<Int>;

@:forward
abstract Path<T:Float>(Array<Point<T>>) from Array<Point<T>> to Array<Point<T>>
{
	public function new()
	{
		this = [];
	}

	/**
		Change `o` coordinates to be on this path.
	**/
	public function constraintObjPos(o : h2d.Object)
	{
		var pC = new FPoint(o.x, o.y);

		var closestProj : FPoint = null;
		var closestProjDist : Float = M.POSITIVE_INFINITY();
		// Find the segment we are on
		for (i in 0...this.length - 1)
		{
			final p1 = this[i];
			final p2 = this[i + 1];
			final v12 = p2 - p1;
			final v12LSq = v12.lengthSq;
			final v1C = pC - p1;

			var dot = v1C.dot(v12);
			var proj : FPoint;
			// Is projection on segment
			if (dot >= 0 && dot <= v12LSq)
			{
				// final cos = dot / (v12.length * v1M.length);
				final normRatio = dot / v12LSq; // same as cos * v1M.length / v12.length
				proj = new FPoint(p1.x + v12.x * normRatio, p1.y + v12.y * normRatio);
			} else if (dot < 0)
				proj = p1.toFPoint();
			else
				proj = p2.toFPoint();

			final projDist = (pC - proj).length;
			if (projDist < closestProjDist)
			{
				closestProj = proj;
				closestProjDist = projDist;
			}
		}

		if (closestProj != null)
		{
			o.x = closestProj.x;
			o.y = closestProj.y;
		}
	}

	#if hlimgui
	static var draggedPoint : FPoint = null;
	public static var selectedInImGui : FPath = null;
	public static var selectedInImGuiForced : FPath = null;
	public function updateImGui(owner : h2d.Object, editAllowed : Bool) : Bool
	{
		ImGui.pushClipRect({x: 0, y: 0}, {x: App.ME.s2d.width, y: App.ME.s2d.height}, false);

		var drawList = ImGui.getWindowDrawList();
		final black = 0xff000000;
		final white = 0xffffffff;
		var lineColor = ImGui.getStyleColorVec4(PlotLines).toColor();
		var lineHoveredColor = ImGui.getStyleColorVec4(PlotLinesHovered).toColor();
		if (!editAllowed)
		{
			lineHoveredColor = lineColor;
			lineColor -= (0x33 << 24);
		}
		final GRAB_RADIUS = 7;
		final CENTER_SIZE = GRAB_RADIUS - 2;
		final CREATE_DIST = 12;

		var size = owner.getBounds(owner);
		var leftTopPoint : Point<T> = new Point(0., 0.).fromObjToGlobal(owner);
		var leftBotPoint : Point<T> = new Point(0., size.height).fromObjToGlobal(owner);
		var righTopPoint : Point<T> = new Point(size.width, 0.).fromObjToGlobal(owner);
		var rightBotPoint : Point<T> = new Point(size.width, size.height).fromObjToGlobal(owner);

		var thisFPath : FPath = cast this;
		if (selectedInImGui == thisFPath)
			drawList.addQuad(leftTopPoint, leftBotPoint, rightBotPoint, righTopPoint, lineHoveredColor, 2);
		else if (selectedInImGuiForced == thisFPath)
			drawList.addQuad(leftTopPoint, leftBotPoint, rightBotPoint, righTopPoint, lineHoveredColor, selectedInImGui == null ? 2 : 1);
		else
			drawList.addQuad(leftTopPoint, leftBotPoint, rightBotPoint, righTopPoint, lineColor - (0x44 << 24));

		// -- Path
		@:privateAccess owner.syncPos();
		var center = new Point(size.width / 2, size.height / 2);
		var cursor = ImGui.getCursorPos();
		var mouse : ImVec2 = ImGui.getMousePos();
		var dragged : Point<T> = draggedPoint;
		var delete : Point<T> = null;
		var pointHighlighted = false;
		var pathUpdated = false;

		// Draw lines and points
		for (i in 0...this.length)
		{
			// Update dragged point position
			if (draggedPoint == this[i])
			{
				final pC = new Point(owner.x, owner.y);
				final pI = this[i];
				final segIC = pC - pI;
				var currNormRatio = 0.;
				var projIBDist = -1.;
				var projIADist = -1.;

				// Before
				if (i > 0)
				{
					final segIB = this[i - 1] - pI;
					final segIBLSq = segIB.lengthSq;
					var dot = segIC.dot(segIB);
					if (dot >= 0 && dot <= segIBLSq)
					{
						final normRatio = dot / segIBLSq;
						var projIB = new Point(pI.x + segIB.x * normRatio, pI.y + segIB.y * normRatio);
						projIBDist = (pC - projIB).length;
						currNormRatio = normRatio;
					}
				}

				// After
				if (i < this.length - 1)
				{
					final segIA = this[i + 1] - pI;
					final segIALSq = segIA.lengthSq;
					var dot = segIC.dot(segIA);
					if (dot >= 0 && dot <= segIALSq)
					{
						final normRatio = dot / segIALSq;
						var projIA = new Point(pI.x + segIA.x * normRatio, pI.y + segIA.y * normRatio);
						projIADist = (pC - projIA).length;
						if (projIADist < projIBDist || projIBDist < 0)
							currNormRatio = normRatio;
					}
				}

				draggedPoint.x = mouse.x;
				draggedPoint.y = mouse.y;
				draggedPoint.fromGlobalToObj(owner.parent);
				draggedPoint.x -= center.x;
				draggedPoint.y -= center.y;

				if (i > 0 && (projIADist < 0 || (projIADist > projIBDist && projIBDist >= 0)))
				{
					final segIB = this[i - 1] - pI;
					owner.x = pI.x + segIB.x * currNormRatio;
					owner.y = pI.y + segIB.y * currNormRatio;
				} else if (projIADist >= 0 && i < this.length - 1)
				{
					final segIA = this[i + 1] - pI;
					owner.x = pI.x + segIA.x * currNormRatio;
					owner.y = pI.y + segIA.y * currNormRatio;
				}

				if (ImGui.isMouseReleased(ImGuiMouseButton.Left))
				{
					dragged = null;
					pathUpdated = true;
				}
			}

			var p = (this[i] + center).fromObjToGlobal(owner.parent);
			// Draw line
			if (i < this.length - 1)
			{
				var pNext = (this[i + 1] + center).fromObjToGlobal(owner.parent);
				drawList.addLine(pNext, p, lineColor, 1);
			}
			// Draw point hovered
			var closeEnough = p.distToP(mouse) < GRAB_RADIUS;
			if (closeEnough) pointHighlighted = true;
			if (editAllowed && closeEnough)
			{
				if (i == 0)
				{
					drawList.addRectFilled(p - GRAB_RADIUS, p + GRAB_RADIUS, black);
					drawList.addRectFilled(p - (GRAB_RADIUS - 1), p + (GRAB_RADIUS - 1), white);
					drawList.addRectFilled(p - (CENTER_SIZE - 1), p + (CENTER_SIZE - 1), lineHoveredColor);
				} else
				{
					drawList.addCircleFilled(p, GRAB_RADIUS, black - 0x33000000);
					drawList.addCircleFilled(p, GRAB_RADIUS - 1, white);
					drawList.addCircleFilled(p, CENTER_SIZE - 1, lineHoveredColor);
				}

				ImGui.setCursorScreenPos(p - GRAB_RADIUS);
				ImGui.setTooltip('${owner.name}@${Std.int(p.x)};${Std.int(p.y)}');
				ImGui.captureMouseFromApp();

				if (draggedPoint == null && ImGui.isMouseDown(ImGuiMouseButton.Left) && ImGui.isMouseDragging(ImGuiMouseButton.Left, 1))
					dragged = this[i];
				else if (ImGui.isMouseClicked(ImGuiMouseButton.Right) && i > 0 && this.length > 2)
					delete = this[i];
			} else
			{
				if (i == 0)
					drawList.addRectFilled(p - CENTER_SIZE, p + CENTER_SIZE, lineHoveredColor);
				else
					drawList.addCircleFilled(p, CENTER_SIZE, lineHoveredColor);
				if (draggedPoint == this[i])
					dragged = null;
			}
		}
		draggedPoint = cast dragged;

		if (delete != null)
		{
			pathUpdated = this.remove(delete) || pathUpdated;
			constraintObjPos(owner);
		}

		// Current position
		drawList.addCircleFilled(new Point(owner.x + center.x, owner.y + center.y).fromObjToGlobal(owner.parent), 3, black - 0x33000000);

		// Projection on the path
		final DOT_MARGIN = GRAB_RADIUS * GRAB_RADIUS * GRAB_RADIUS;
		var closestProj : Point<T> = null;
		var closestProjDist : Float = CREATE_DIST;
		var closestIdx = 0;
		var closestProgress = 0.;
		var progress = 0.;
		// Find the segment we are on
		for (i in 0...this.length - 1)
		{
			final p1 : Point<T> = (this[i] + center).fromObjToGlobal(owner.parent);
			final p2 = (this[i + 1] + center).fromObjToGlobal(owner.parent);
			final v12 = p2 - p1;
			final v12LSq = v12.lengthSq;
			final v1M : Point<T> = mouse - p1;

			var dot = v1M.dot(v12);
			// Is projection on segment (and not to close from the ends)
			if (dot >= DOT_MARGIN && dot <= v12LSq - DOT_MARGIN)
			{
				final normRatio = dot / v12LSq;
				final proj = new Point(p1.x + v12.x * normRatio, p1.y + v12.y * normRatio);
				final projDist = (mouse - proj : Point<T>).length;
				if (projDist < closestProjDist)
				{
					closestProj = proj;
					closestProjDist = projDist;
					closestIdx = i;
					closestProgress = progress + normRatio * Math.sqrt(v12LSq);
				}
			}
			progress += Math.sqrt(v12LSq);
		}

		if (closestProj != null)
		{
			pointHighlighted = true;

			ImGui.setCursorScreenPos(closestProj);
			ImGui.setTooltip('${owner.name}@${Std.int(closestProj.x)};${Std.int(closestProj.y)}-${Std.int(100 * closestProgress / progress)}%');
			if (editAllowed) ImGui.captureMouseFromApp();

			// Create new point
			if (editAllowed && ImGui.isMouseClicked(ImGuiMouseButton.Left))
			{
				this.insert(closestIdx + 1, closestProj.fromGlobalToObj(owner.parent) - center);
				pathUpdated = true;
			} else
			{
				drawList.addCircleFilled(closestProj, CENTER_SIZE, lineHoveredColor - 0x66000000);
			}
		}

		ImGui.popClipRect();

		// Restore cursor pos
		ImGui.setCursorPos(cursor);

		var hovered = App.ME.s2d.getInteractive(App.ME.s2d.mouseX, App.ME.s2d.mouseY) == owner;
		if (selectedInImGui == thisFPath)
		{
			if (!hovered && !pointHighlighted)
				selectedInImGui = null;
		} else if (selectedInImGuiForced != thisFPath && (pointHighlighted || (selectedInImGui == null && hovered)))
		{
			selectedInImGui = thisFPath;
		}

		return pathUpdated;
	}
	#end
}