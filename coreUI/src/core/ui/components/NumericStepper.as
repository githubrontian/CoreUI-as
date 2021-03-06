/**
 * NumericStepper.as
 * 
 * Wraps a NumberInputField and provides up/down buttons for changing the value with the mouse.
 * 
 * Copyright (c) 2011 Jonathan Pace
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package core.ui.components 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import core.ui.events.ItemEditorEvent;
	import core.events.PropertyChangeEvent;
	import core.ui.managers.FocusManager;
	import flux.skins.NumericStepperDownBtnSkin;
	import flux.skins.NumericStepperUpBtnSkin;
	
	public class NumericStepper extends UIComponent 
	{
		private static const DELAY_TIME		:int = 500;
		private static const REPEAT_TIME	:int = 100;
		
		// Styles
		public static var styleGap		:int = -1;
		
		// Properties
		private var _stepSize			:Number = 1;
		private var _gap				:int = styleGap;
		
		// Child elements
		private var inputField			:NumberInput;
		private var upBtn				:Button;
		private var downBtn				:Button;
		
		// Internal vars
		private var delayTimer			:Timer;
		private var repeatTimer			:Timer;
		private var repeatDirection		:Number;
		
		public function NumericStepper() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			focusEnabled = true;
			
			inputField = new NumberInput();
			inputField.focusEnabled = false;
			inputField.addEventListener(Event.CHANGE, onInputFieldChange);
			inputField.addEventListener(ItemEditorEvent.COMMIT_VALUE, onInputFieldCommitValue);
			addChild(inputField);
			
			_width = inputField.width;
			_height = inputField.height;
			
			upBtn = new Button(NumericStepperUpBtnSkin);
			upBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownButtonHandler);
			upBtn.focusEnabled = false;
			addChild(upBtn);
			
			downBtn = new Button(NumericStepperDownBtnSkin);
			downBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownButtonHandler);
			downBtn.focusEnabled = false;
			addChild(downBtn);
			
			delayTimer = new Timer( DELAY_TIME, 1 );
			delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayCompleteHandler);
			repeatTimer = new Timer( REPEAT_TIME, 0 );
			repeatTimer.addEventListener(TimerEvent.TIMER, repeatHandler);
		}
		
		override protected function validate():void
		{
			inputField.width = (_width - upBtn.width) - _gap;;
			inputField.height = _height;
			inputField.validateNow();
			
			upBtn.height = _height >> 1;
			upBtn.x = inputField.width + _gap;
			
			downBtn.height = _height - upBtn.height;
			downBtn.x = upBtn.x;
			downBtn.y = upBtn.height;
		}
		
		override public function onGainComponentFocus():void
		{
			inputField.onGainComponentFocus();
		}
		
		override public function onLoseComponentFocus():void
		{
			inputField.onLoseComponentFocus();
		}
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		private function onInputFieldChange( event:Event ):void
		{
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		private function onInputFieldCommitValue( event:ItemEditorEvent ):void
		{
			dispatchEvent( new ItemEditorEvent( ItemEditorEvent.COMMIT_VALUE, event.value, "value" ) );
		}
		
		private function mouseDownButtonHandler( event:MouseEvent ):void
		{
			repeatDirection = event.target == upBtn ? 1 : -1;
			value += repeatDirection * _stepSize;
			delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, endRepeatHandler);
			event.target.addEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
		}
		
		private function endRepeatHandler( event:MouseEvent ):void
		{
			upBtn.removeEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
			downBtn.removeEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endRepeatHandler);
			delayTimer.stop();
			repeatTimer.stop();
		}
		
		private function delayCompleteHandler( event:TimerEvent ):void
		{
			repeatTimer.start();
		}
		
		private function repeatHandler( event:TimerEvent ):void
		{
			value += repeatDirection * _stepSize;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set stepSize( v:Number ):void
		{
			_stepSize = v;
		}
		
		public function get stepSize():Number
		{
			return _stepSize;
		}
		
		public function set value( v:Number ):void
		{
			if ( v == inputField.value ) return;
			var oldValue:Number = inputField.value;
			inputField.value = v;
			if ( inputField.value == oldValue ) return;
			dispatchEvent( new Event( Event.CHANGE ) );
			dispatchEvent( new PropertyChangeEvent( "propertyChange_value", oldValue, inputField.value ) );
		}
		
		public function get value():Number
		{
			return inputField.value;
		}
		
		public function set min( v:Number ):void
		{
			inputField.min = v;
		}
		
		public function get min():Number
		{
			return inputField.min
		}
		
		public function set max( v:Number ):void
		{
			inputField.max = v;
		}
		
		public function get max():Number
		{
			return inputField.max;
		}
		
		public function set numDecimalPlaces( v:uint ):void
		{
			inputField.numDecimalPlaces = v;
		}
		
		public function get numDecimalPlaces():uint
		{
			return inputField.numDecimalPlaces;
		}
		
		public function get gap():int 
		{
			return _gap;
		}
		
		public function set gap(value:int):void 
		{
			if ( value == _gap ) return;
			_gap = value;
			invalidate();
		}
	}
}