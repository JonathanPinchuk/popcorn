% Author: Jonathan Pinchuk
%
% Analyse and present popcorn popping sound wav files
%

main()

function main()
    files = ["recordings/Popcorn100v1.wav";
             "recordings/Popcorn100v2.wav";
             "recordings/Popcorn100v3.wav";
             "recordings/Popcorn100v4.wav";
             "recordings/Popcorn100v5.wav";
             "recordings/Popcorn200v1.wav";
             "recordings/Popcorn200v2.wav";
             "recordings/Popcorn200v3.wav"]';

    tiledlayout(4,4);

    for i = 1:8
        [sampled_amplitude,Fs] = audioread(files(i));
        number_of_samples = size(sampled_amplitude, 1);
        normalised_sampled_amplitude = normalise(sampled_amplitude);
        indices = getSampleIndicesAboveThreshold(normalised_sampled_amplitude, 0.3);

        plotNormalizedSampleAmplitude(normalised_sampled_amplitude, i);
        histogram_result = plotSampleIndicesHistogram(indices, 7);
        histogram_bin_values = histogram_result(1).Values;

        bin_width = histogram_result(1).BinWidth;
        scaled_gauss_curve = getScaledGaussCurve(indices, number_of_samples, bin_width);

        addScaledGaussCurveToHistogram(scaled_gauss_curve);
        bin_iterator = getBinIterator(histogram_result);
        bin_indices = getBinIndices(histogram_result, bin_iterator);
        addDiscreteGaussValues(histogram_result, scaled_gauss_curve, bin_width, bin_iterator, bin_indices);
        chi2 = myChi2(histogram_bin_values, scaled_gauss_curve, bin_indices);
        addTitleToHistogram(chi2, i);
    end
end

function addTitleToHistogram(chi2, i)
    title(strcat("Histogram opname ", num2str(i)), 'FontSize', 16);
    subtitle(strcat("X^2 = ", num2str(chi2)), 'FontSize', 14);
end

function addDiscreteGaussValues(histogram_result, scaled_gauss_curve, bin_width, bin_iterator, bin_indices)
    hold on;
    plot(histogram_result(1).BinLimits(1) + (bin_iterator - 0.5) * bin_width,scaled_gauss_curve(bin_indices), 'Color', '#664c00', 'marker', '.', 'LineStyle', 'none');
end

function f = getBinIterator(histogram_result)
    n_bins = histogram_result(1).NumBins;
    f = [1:n_bins];
end

function f = getBinIndices(histogram_result, bin_iterator)
    bins(1, bin_iterator) = histogram_result(1).BinEdges(bin_iterator);
    bins(2, bin_iterator) = histogram_result(1).BinEdges(bin_iterator + 1);
    bin_indices(bin_iterator) = round(mean(bins));
    f = bin_indices;
end

function f = myChi2(histogram_bin_values, scaled_gauss_curve, bin_indices)
    % Could not make chi2gof to work, and therefore calculate it myself.
    % [h,p] = chi2gof(histogram_bin_values,'NBins',4);
    chi2vector = ((scaled_gauss_curve(bin_indices) - histogram_bin_values).^2) ./ (scaled_gauss_curve(bin_indices));
    f = sum(chi2vector);
end

function addScaledGaussCurveToHistogram(scaled_gauss_curve)
    hold on;
    plot(scaled_gauss_curve, 'Color', '#664c00');
end

function f = getScaledGaussCurve(indices, number_of_samples, bin_width)
    mu = mean(indices);
    sigma = std(indices);
    gauss_curve = normpdf(0:number_of_samples, mu, sigma);
    f = bin_width * gauss_curve;
end

function result = plotSampleIndicesHistogram(indices, number_of_bins)
    nexttile;
    result = histogram(indices, number_of_bins, 'Normalization', 'probability', 'FaceColor', '#cc9900');
end

function plotNormalizedSampleAmplitude(normalised_sampled_amplitude, i)
    nexttile;
    plot(normalised_sampled_amplitude, 'Color', '#cc9900');
    title(strcat("Opname ", num2str(i)), 'FontSize', 16);
end

function f = getSampleIndicesAboveThreshold(samples, threshold)
    samples = noiseReduction(samples, threshold);
    f = getNonZeroSampleIndices(samples);
end

function f = getNonZeroSampleIndices(samples)
    f = find(samples);
end

function f = normalise(v)
    f = v / max(v);
end

function f = noiseReduction(v, threshold)
    v = abs(v);
    v(v < threshold) = 0;
    f = v;
end