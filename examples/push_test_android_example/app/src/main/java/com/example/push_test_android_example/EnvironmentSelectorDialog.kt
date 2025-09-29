package com.example.push_test_android_example

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat

class EnvironmentSelectorDialog(
    private val context: Context,
    private val currentEnvironment: Environment,
    private val onEnvironmentSelected: (Environment) -> Unit
) {
    
    fun show() {
        val dialogView = LayoutInflater.from(context).inflate(R.layout.dialog_environment_selector, null)
        
        val dialog = AlertDialog.Builder(context)
            .setTitle("Select Environment")
            .setView(dialogView)
            .setNegativeButton("Cancel", null)
            .create()
        
        setupEnvironmentOptions(dialogView, dialog)
        
        dialog.show()
    }
    
    private fun setupEnvironmentOptions(dialogView: View, dialog: Dialog) {
        val environmentsContainer = dialogView.findViewById<LinearLayout>(R.id.environmentsContainer)
        
        Environment.values().forEach { environment ->
            val environmentView = createEnvironmentView(environment, dialog)
            environmentsContainer.addView(environmentView)
        }
    }
    
    private fun createEnvironmentView(environment: Environment, dialog: Dialog): View {
        val view = LayoutInflater.from(context).inflate(R.layout.item_environment, null)
        
        val nameText = view.findViewById<TextView>(R.id.environmentName)
        val endpointText = view.findViewById<TextView>(R.id.environmentEndpoint)
        val descriptionText = view.findViewById<TextView>(R.id.environmentDescription)
        val badge = view.findViewById<TextView>(R.id.environmentBadge)
        val selectedIndicator = view.findViewById<View>(R.id.selectedIndicator)
        
        nameText.text = environment.displayName
        endpointText.text = environment.endpoint
        descriptionText.text = environment.description
        badge.text = environment.displayName
        
        // Set badge color
        val badgeColor = when (environment) {
            Environment.PRODUCTION -> ContextCompat.getColor(context, android.R.color.holo_green_dark)
            Environment.STAGING -> ContextCompat.getColor(context, android.R.color.holo_orange_dark)
            Environment.DEVELOPMENT -> ContextCompat.getColor(context, android.R.color.holo_blue_dark)
        }
        badge.setBackgroundColor(badgeColor)
        
        // Show selection indicator if current environment
        selectedIndicator.visibility = if (environment == currentEnvironment) View.VISIBLE else View.GONE
        
        // Set background for selected item
        if (environment == currentEnvironment) {
            view.setBackgroundColor(ContextCompat.getColor(context, android.R.color.holo_blue_bright))
            view.alpha = 0.3f
        }
        
        view.setOnClickListener {
            dialog.dismiss()
            if (environment != currentEnvironment) {
                showConfirmationDialog(environment)
            }
        }
        
        return view
    }
    
    private fun showConfirmationDialog(environment: Environment) {
        AlertDialog.Builder(context)
            .setTitle("Switch Environment")
            .setMessage(
                "Switch to ${environment.displayName}?\n\n" +
                "Endpoint: ${environment.endpoint}\n\n" +
                "This will reinitialize the SDK with the new environment."
            )
            .setPositiveButton("Switch") { _, _ ->
                onEnvironmentSelected(environment)
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
}
