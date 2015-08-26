﻿#pragma checksum "..\..\..\Controls\PartySelector.xaml" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "74A33304F06602A3800BD21DE00FC42C"
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.225
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Media.TextFormatting;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Shell;


namespace Shell.Controls {
    
    
    /// <summary>
    /// PartySelector
    /// </summary>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
    public partial class PartySelector : System.Windows.Controls.UserControl, System.Windows.Markup.IComponentConnector {
        
        
        #line 9 "..\..\..\Controls\PartySelector.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox PawnNumberText;
        
        #line default
        #line hidden
        
        
        #line 13 "..\..\..\Controls\PartySelector.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox LastNameText;
        
        #line default
        #line hidden
        
        
        #line 15 "..\..\..\Controls\PartySelector.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox FirstNameText;
        
        #line default
        #line hidden
        
        
        #line 17 "..\..\..\Controls\PartySelector.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox BarcodeText;
        
        #line default
        #line hidden
        
        
        #line 22 "..\..\..\Controls\PartySelector.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.ListView PartiesListView;
        
        #line default
        #line hidden
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Uri resourceLocater = new System.Uri("/HyperPawn;component/controls/partyselector.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\..\Controls\PartySelector.xaml"
            System.Windows.Application.LoadComponent(this, resourceLocater);
            
            #line default
            #line hidden
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        void System.Windows.Markup.IComponentConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 1:
            this.PawnNumberText = ((System.Windows.Controls.TextBox)(target));
            
            #line 9 "..\..\..\Controls\PartySelector.xaml"
            this.PawnNumberText.KeyDown += new System.Windows.Input.KeyEventHandler(this.SearchText_KeyDown);
            
            #line default
            #line hidden
            return;
            case 2:
            this.LastNameText = ((System.Windows.Controls.TextBox)(target));
            
            #line 13 "..\..\..\Controls\PartySelector.xaml"
            this.LastNameText.KeyDown += new System.Windows.Input.KeyEventHandler(this.SearchText_KeyDown);
            
            #line default
            #line hidden
            return;
            case 3:
            this.FirstNameText = ((System.Windows.Controls.TextBox)(target));
            
            #line 15 "..\..\..\Controls\PartySelector.xaml"
            this.FirstNameText.KeyDown += new System.Windows.Input.KeyEventHandler(this.SearchText_KeyDown);
            
            #line default
            #line hidden
            return;
            case 4:
            this.BarcodeText = ((System.Windows.Controls.TextBox)(target));
            
            #line 17 "..\..\..\Controls\PartySelector.xaml"
            this.BarcodeText.KeyDown += new System.Windows.Input.KeyEventHandler(this.BarcodeText_KeyDown);
            
            #line default
            #line hidden
            return;
            case 5:
            
            #line 19 "..\..\..\Controls\PartySelector.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.NewCustomer_Click);
            
            #line default
            #line hidden
            return;
            case 6:
            this.PartiesListView = ((System.Windows.Controls.ListView)(target));
            return;
            }
            this._contentLoaded = true;
        }
    }
}

