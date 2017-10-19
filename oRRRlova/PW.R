#��������������� �������
mc.dist = function(p1, p2) sqrt(sum((p1 - p2) ^ 2)) #��������� ����������
mc.distances = function(points, u) apply(points, 1, mc.dist, u) #���������� �� ���� points �� ����� u
mc.sumByClass = function(class, arr) sum(arr[names(arr) == class]) #��������� �������� ������� ������
mc.contains = function(points, u) any(apply(points, 1, function(v) all(v == u)))

plot.limits = function(arr, deviation = 0) c(min(arr) - deviation, max(arr) + deviation) #����������� � ������������ �������� � �����������

#����
mc.kernel.R = function(r) 0.5 * (abs(r) <= 1) #�������������
mc.kernel.T = function(r) (1 - abs(r)) * (abs(r) <= 1) #�����������
mc.kernel.Q = function(r) (15 / 16) * (1 - r ^ 2) ^ 2 * (abs(r) <= 1) #������������
mc.kernel.E = function(r)(3 / 4) * (1 - r ^ 2) * (abs(r) <= 1) #������������

mc.PW.kernel = mc.kernel.R #������������ ��� ����

#PW
mc.PW = function(distances, u, h) {
    weights = mc.PW.kernel(distances / h)
    classes = unique(names(distances))

    weightsByClass = sapply(classes, mc.sumByClass, weights)

    if (max(weightsByClass) == 0) return("") #�� ���� ����� �� ������ � ����

    return(names(which.max(weightsByClass)))
}

#LOO
mc.LOO.PW = function(points, classes, hValues) {
    n = dim(points)[1]
    loo = rep(0, length(hValues))

    for (i in 1:n) {
        u = points[i,]
        sample = points[-i,]
        distances = mc.distances(sample, u)
        names(distances) = classes[-i]

        for (j in 1:length(hValues)) {
            h = hValues[j]
            classified = mc.PW(distances, u, h)
            loo[j] = loo[j] + (classified != classes[i])
        }
    }

    loo = loo / n
}

#��������� LOO
mc.draw.LOO.PW = function(points, classes, hValues) {
    loo = mc.LOO.PW(points, classes, hValues)

    x = hValues
    y = loo

    plot(x, y, type = "l", main = "LOO ��� ������������� ���� (PW)", xlab = "h", ylab = "LOO", col.lab = "blue")

    h = hValues[which.min(loo)]
    h.loo = round(loo[which.min(loo)], 4)

    points(h, h.loo, pch = 19, col = "blue")
    label = paste("h = ", h, "\n", "LOO = ", h.loo, sep = "")
    text(h, h.loo, labels = label, pos = 3, col = "blue", family = "mono", font = 2)

    return(h)
}

#��������� ����� �������������
mc.draw.PW = function(points, classes, colors, h) {
    uniqueClasses = unique(classes)
    names(colors) = uniqueClasses

    x = points[, 1]
    y = points[, 2]
    xlim = plot.limits(x, 0.3)
    ylim = plot.limits(y, 0.3)
    plot(points, bg = colors[classes], pch = 21, asp = 1, xlim = xlim, ylim = ylim, main = "����� ������������� PW", col.lab = "blue") #������ ��������� �����

    #�������������� �����
    step = 0.1
    ox = seq(xlim[1], xlim[2], step)
    oy = seq(ylim[1], ylim[2], step)

    for (x in ox) {
        for (y in oy) {
            x = round(x, 1) #�������� ������� 0.1 + 0.2 = 0.3000000004
            y = round(y, 1) #�������� ������� 0.1 + 0.2 = 0.3000000004
            u = c(x, y)

            if (mc.contains(points, u)) next #�� ���������������� ��������� �����

            distances = mc.distances(points, u)
            names(distances) = classes
            classified = mc.PW(distances, u, h)

            #������ ����� ������������������ �����
            points(u[1], u[2], col = colors[classified], pch = 21) #u
        }
    }

    legend("topright", legend = uniqueClasses, pch = 21, pt.bg = colors[uniqueClasses], xpd = T) #������� ������� ��� ������� �������
}

#��������� ���������
test = function() {
    petals = iris[, 3:4]
    petalNames = iris[, 5]

    par(mfrow = c(1, 2))
    h = mc.draw.LOO.PW(petals, petalNames, hValues = seq(0.1, 2, 0.005))
    mc.draw.PW(petals, petalNames, colors = c("red", "green3", "blue"), h = h)
}