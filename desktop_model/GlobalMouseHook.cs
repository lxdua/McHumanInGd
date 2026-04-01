using Godot;
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public partial class GlobalMouseHook : Node
{
	[Signal]
	public delegate void GlobalMouseClickEventHandler(int buttonIndex);

	private const int WH_MOUSE_LL = 14;
	private const int WM_LBUTTONDOWN = 0x0201;
	private const int WM_RBUTTONDOWN = 0x0204;

	private delegate IntPtr LowLevelMouseProc(int nCode, IntPtr wParam, IntPtr lParam);
	private LowLevelMouseProc _proc;
	private IntPtr _hookID = IntPtr.Zero;

	// --- Windows API 声明 ---
	[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
	private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelMouseProc lpfn, IntPtr hMod, uint dwThreadId);

	[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
	[return: MarshalAs(UnmanagedType.Bool)]
	private static extern bool UnhookWindowsHookEx(IntPtr hhk);

	[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
	private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

	[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
	private static extern IntPtr GetModuleHandle(string lpModuleName);

	public override void _Ready()
	{
		// 保持对委托的引用，防止被垃圾回收
		_proc = HookCallback;
		_hookID = SetHook(_proc);
	}

	public override void _ExitTree()
	{
		// 节点销毁时务必卸载钩子
		if (_hookID != IntPtr.Zero)
		{
			UnhookWindowsHookEx(_hookID);
			_hookID = IntPtr.Zero;
		}
	}

	private IntPtr SetHook(LowLevelMouseProc proc)
	{
		using (Process curProcess = Process.GetCurrentProcess())
		using (ProcessModule curModule = curProcess.MainModule)
		{
			return SetWindowsHookEx(WH_MOUSE_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
		}
	}

	private IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
	{
		if (nCode >= 0)
		{
			if (wParam == (IntPtr)WM_LBUTTONDOWN)
			{
				EmitSignal(SignalName.GlobalMouseClick, 1);
			}
			else if (wParam == (IntPtr)WM_RBUTTONDOWN)
			{
				EmitSignal(SignalName.GlobalMouseClick, 2);
			}
		}
		
		// 将事件传递给系统中的下一个钩子
		return CallNextHookEx(_hookID, nCode, wParam, lParam);
	}
}
