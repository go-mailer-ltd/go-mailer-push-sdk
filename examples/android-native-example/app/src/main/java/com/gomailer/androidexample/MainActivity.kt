package com.gomailer.androidexample

import android.content.Intent
import android.os.Bundle
import android.widget.ArrayAdapter
import androidx.appcompat.app.AppCompatActivity
import com.gomailer.androidexample.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupUI()
    }

    private fun setupUI() {
        // Setup environment spinner
        val environments = arrayOf("development", "staging", "production")
        val adapter = ArrayAdapter(this, android.R.layout.simple_dropdown_item_1line, environments)
        binding.environmentSpinner.setAdapter(adapter)
        binding.environmentSpinner.setText("development", false)
        
        // Set default API key
        binding.apiKeyInput.setText("TmF0aGFuLTEyMzQ1Njc4OTA=")
        
        binding.continueButton.setOnClickListener {
            val apiKey = binding.apiKeyInput.text.toString().trim()
            if (apiKey.isEmpty()) {
                binding.apiKeyInputLayout.error = "Please enter API key"
                return@setOnClickListener
            }
            
            binding.apiKeyInputLayout.error = null
            
            val environment = binding.environmentSpinner.text.toString()
            
            val intent = Intent(this, TestActivity::class.java)
            intent.putExtra("apiKey", apiKey)
            intent.putExtra("environment", environment)
            startActivity(intent)
        }
    }
}